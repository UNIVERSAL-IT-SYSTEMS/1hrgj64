config = require "lapis.config"
import sql_password, session_secret from require "secret"

config "production", ->
    session_name "1hrgj64"
    secret session_secret
    postgres ->
        host "127.0.0.1"
        user "postgres"
        password sql_password
        database "1hrgj64"
    port 9278
    num_workers 8
    code_cache "on"
    githook true
