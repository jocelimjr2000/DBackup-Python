Config.json

> General definitions:
>~~~~
>   "parameters": {
>       "tmpFolder": "./tmp",           * (Required) Temporary folder to dump databases
>       "logFolder": "./log",           * (Required) Log folder
>       "separatedFiles": false,        * (Required) Dump separated files (table.sql) for all servers and databases
>       "compressTo" : "zip"            * (Opitional) The compression type for all servers and databases (Options: zip)
>   },
>~~~~
> Servers list
>~~~~
>   "servers": [
>       {
>           "name": "home",               * (Required) Name server (Reference for this backup)
>           "prefix": "server01_",        * (Required) Prefix for file name
>           "host": "127.0.0.1",          * (Required) Host
>           "port": 3306,                 * (Required) Port
>           "user": "root",               * (Required) User name
>           "password": "",               * (Required) Password
>           "separatedFiles": false,      * (Opitional) Dump separated files (table.sql) for all databases on this server
>           "compressTo" : "zip",         * (Opitional) The compression type for all databases on this server (Options: zip)
>      
>           - List databases (Basic)
>           "databases": [                
>               "db1", "db2"                * (Required) Database's name
>           ],
>
>           - List databases (Advanced)
>           "databases": [                
>               {
>                   "name": "infinity",       * (Required) Database's name
>                   "separatedFiles": true,   * (Opitional) Dump separated files (table.sql) for this database
>                   "compressTo" : "zip"      * (Opitional) The compression type for this database (Options: zip)
>               },
>           ]
>       }
>   ],
> ~~~~
> Save backup files 
> ~~~~
>   "storage": {
> 
>       - Disable
>       "type": false  
> 
>       - Set destination folder
>       "type": "folder"
>       "to": "/folder"                     * (Required) Destination folder
> 
>   } 
> ~~~~

~~~~
Basic example
 
{
  "parameters": {
    "tmpFolder": "./tmp",
    "logFolder": "./log",
    "separatedFiles": false,
    "compressTo" : "zip"
  },
  "servers": [
    {
      "name": "home",
      "prefix": "server01_",
      "host": "127.0.0.1",
      "port": 3306,
      "user": "root",
      "password": "",
      "separatedFiles": false,
      "compressTo" : "zip",
      "databases": [
        "db1", "db2"
      ],
    }
  ],
  "storage": {
    "type": false
  } 
}
~~~~
