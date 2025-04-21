#!/bin/bash


DB_FILE="/var/lib/kraken/db/kraken.db"


 
sql_escape() {
    sed "s/'/''/g" <<< "$1"
}

get_pkg_id() {
    local pkgname=$(sql_escape "$1")
    local version=$(sql_escape "$2")
    
    sqlite3 "$DB_FILE" <<EOF
SELECT id FROM packages 
WHERE name = '$pkgname' AND version = '$version';
EOF
}






mark_downloaded() {
    local pkgname=$(sql_escape "$1")
    local version=$(sql_escape "$2")
    local category=$(sql_escape "$3")

    sqlite3 "$DB_FILE" <<EOF
BEGIN TRANSACTION;
INSERT INTO packages (name, version, category)
VALUES ('$pkgname', '$version', '$category');

INSERT INTO installation_steps (package_id, downloaded)
VALUES (last_insert_rowid(), 1);
COMMIT;
EOF
    return $?
}

mark_prepared() {
    local pkg_id=$(sql_escape "$1")
    
    sqlite3 "$DB_FILE" <<EOF
BEGIN TRANSACTION;
UPDATE installation_steps
SET prepared = 1
WHERE package_id = $pkg_id;
COMMIT;
EOF
    return $?
}


mark_builded() {
    local pkg_id=$(sql_escape "$1")
    
    sqlite3 "$DB_FILE" <<EOF
BEGIN TRANSACTION;
UPDATE installation_steps
SET builded = 1
WHERE package_id = $pkg_id;
COMMIT;
EOF
    return $?
}


mark_fake_installed() {
    local pkg_id=$(sql_escape "$1")
    
    sqlite3 "$DB_FILE" <<EOF
BEGIN TRANSACTION;
UPDATE installation_steps
SET fakeinstalled = 1
WHERE package_id = $pkg_id;
COMMIT;
EOF
    return $?
}

mark_installed() {
    local pkg_id=$(sql_escape "$1")
    
    sqlite3 "$DB_FILE" <<EOF
BEGIN TRANSACTION;
UPDATE installation_steps
SET installed = 1
WHERE package_id = $pkg_id;
COMMIT;
EOF
    return $?
}


mark_postinstalled() {
    local pkg_id=$(sql_escape "$1")
    
    sqlite3 "$DB_FILE" <<EOF
BEGIN TRANSACTION;
UPDATE installation_steps
SET postinstalled = 1
WHERE package_id = $pkg_id;
COMMIT;
EOF
    return $?
}







check_steps() {
    local pkg_id=$(sql_escape "$1")
    local step=$(sql_escape "$2")
    
    sqlite3 "$DB_FILE" <<EOF
SELECT $step FROM installation_steps
WHERE package_id = $pkg_id;
EOF
}



verifyall_steps() {
    local pkg_id=$(sql_escape "$1")
    
   
    local status=$(sqlite3 -line "$DB_FILE" <<EOF
SELECT * FROM installation_steps 
WHERE package_id = $pkg_id;
EOF
    )

    
    if echo "$status" | grep -qE 'downloaded\s*=\s*1' && \
       echo "$status" | grep -qE 'prepared\s*=\s*1' && \
       echo "$status" | grep -qE 'builded(ed)?\s*=\s*1' && \
       echo "$status" | grep -qE 'fakeinstalled\s*=\s*1' && \
       echo "$status" | grep -qE 'installed\s*=\s*1' && \
       echo "$status" | grep -qE 'postinstalled\s*=\s*1'; then
        
       
        sqlite3 "$DB_FILE" <<EOF
BEGIN TRANSACTION;
UPDATE packages SET
    installed = 1,
    date = datetime('now')
WHERE id = $pkg_id;
COMMIT;
EOF
        return 0
    else
        
        echo "Missing steps:"
        echo "$status" | awk -F' = ' '/ 0$/ {print $1}'
        return 1
    fi
}


remove_package() {
    local pkgname=$(sql_escape "$1")
    local pkgver=$(sql_escape "$2")
    
    local pkg_id=$(sqlite3 "$DB_FILE" \
        "SELECT id FROM packages WHERE ((name = '$pkgname') AND (version = '$version'));")
    
    if [ -z "$pkg_id" ]; then
        echo "Package $pkgname not found in database"
        return 1
    fi

    
    sqlite3 "$DB_FILE" <<EOF
BEGIN TRANSACTION;
DELETE FROM installation_steps WHERE package_id = $pkg_id;
DELETE FROM packages WHERE id = $pkg_id;
COMMIT;
EOF

    if [ $? -eq 0 ]; then
        echo "Successfully removed $pkgname"
        return 0
    else
        echo "Failed to remove $pkgname"
        return 1
    fi
}