  variable tab_cols  {
  description = "Table Colums" 
  default = [["name:my_string","type:string","comments:string column"]
            ,["name:my_double","type:double","comments:double column"]
            ,["name:my_date","type:date","comments:date column"]
            ,["name:my_bigint","type:my_bigint","comments:big int column"]]
}

variable tab_name {
  description = "Table Name" 
  default = "test_tab"

}

variable context_databaset_name {
  description = "Database Name" 
  default = "lakedatabasedummycontext"
}

