#!/bin/bash


DB_FILE="/var/lib/kraken/kraken.db"


# to escape sql special characters shit 
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
SET fake_installed = 1
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
