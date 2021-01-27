Config.json

~~~~
{
  "parameters": {                   - General definitions
    "tmpFolder": "./tmp",           * (Required) Temporary folder to dump databases
    "separatedFiles": false         * (Required) Dump separated files (table.sql) for all servers and databases
  },
  "servers": [                      - List servers
    {
      "name": "home",               * (Required) Name server (Reference for this backup)
      "prefix": "server01_",        * (Required) Prefix for file name
      "host": "127.0.0.1",          * (Required) Host
      "port": 3306,                 * (Required) Port
      "user": "root",               * (Required) User name
      "password": "",               * (Required) Password
      "separatedFiles": false,      * (Opitional) Dump separated files (table.sql) for all databases on this server
      "databases": [                - List databases (Basic)
        "db1", "db2"                * (Required) Database's name
      ],
      "databases": [                - List databases (Advanced)
        {
          "name": "infinity",       * (Required) Database's name
          "separatedFiles": true    * (Opitional) Dump separated files (table.sql) for this database
        }
      ]
    }
  ],
  "hdds": [                         - List disks
    "/mnt/hdd1", "/mnt/hdd2"        * (Required) Disks to save backup
  ] 
}
~~~~
