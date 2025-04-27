CREATE TABLE packages (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    version TEXT NOT NULL,
    category TEXT NOT NULL,
    installed INTEGER DEFAULT 0,
    date DATETIME ,
    UNIQUE(name, version)  
);

CREATE TABLE installation_steps (
    package_id INTEGER,
    downloaded INTEGER DEFAULT 0,
    prepared INTEGER DEFAULT 0,
    builded INTEGER DEFAULT 0,
    fakeinstalled INTEGER DEFAULT 0,
    installed INTEGER DEFAULT 0,
    postinstalled INTEGER DEFAULT 0,
    FOREIGN KEY(package_id) REFERENCES packages(id)
);