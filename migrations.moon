import create_table from require "lapis.db.schema"

{
	[1]: =>
		create_table "users", {
			{"id", types.serial primary_key: true}
			{"name", types.text unique: true}
			{"password", types.text}
		}
}
