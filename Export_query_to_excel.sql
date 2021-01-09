--------------------------------------------------------
--  Date  : 2005/08/09
--  Owner : SQLcl.com
--  ver   : 2.00
--------------------------------------------------------

create or replace procedure 

export_query_to_file
( 
 p_query in varchar2 ,
 arg_file_name varchar2,
 arg_sepreator varchar2,
 arg_header varchar2
) authid current_user is
     l_thecursor        integer default dbms_sql.open_cursor;
     l_columnvalue      varchar2(4000);
     l_status           integer;
     l_desctbl          dbms_sql.desc_tab;
     l_colcnt           number;
     v_out_file         utl_file.file_type;
     v_flag number (1)  := 1 ;
     begin
 
 
 -- EXPORT_DIR is mounted Oracle path in server.
 v_out_file := utl_file.fopen('EXPORT_DIR' ,arg_file_name, 'w');
 
 dbms_sql.parse(l_thecursor,p_query,dbms_sql.native);
 dbms_sql.describe_columns( l_thecursor, l_colcnt, l_desctbl);

      for i in 1 .. l_colcnt loop
         dbms_sql.define_column(l_thecursor, i, l_columnvalue, 4000);
      end loop;

      l_status := dbms_sql.execute(l_thecursor);


while ( dbms_sql.fetch_rows(l_thecursor) > 0 ) loop
 if  upper(arg_header) = 'YES' and v_flag = 1 then     
   
      v_flag := 0 ;
      for i in 1 .. l_colcnt loop
  
          dbms_sql.column_value( l_thecursor, i, l_columnvalue );
              
          if upper(arg_sepreator) = 'XLS' then
                utl_file.put(v_out_file,l_desctbl(i).col_name||chr(9)) ;
          else
                if i= l_colcnt then
                  utl_file.put(v_out_file,l_desctbl(i).col_name) ;
                else
                  utl_file.put(v_out_file,l_desctbl(i).col_name||arg_sepreator) ;
                end if ;
          end if ;
      end loop ;

  utl_file.put(v_out_file,chr(13) || chr(10)) ;
 	utl_file.fflush(v_out_file); 
  
 end if ;

 for i in 1 .. l_colcnt loop
  
    dbms_sql.column_value( l_thecursor, i, l_columnvalue );

    if upper(arg_sepreator) = 'XLS' then
        utl_file.put(v_out_file,l_columnvalue||chr(9)) ;
    else       
      if i= l_colcnt then
         utl_file.put(v_out_file,l_columnvalue) ;
      else
         utl_file.put(v_out_file,l_columnvalue||arg_sepreator) ;
      end if ;
    end if ;
  end loop;
          
  utl_file.put(v_out_file,chr(13) || chr(10)) ;
  utl_file.fflush( v_out_file);  
end loop;
   
     utl_file.fclose(v_out_file);
  exception
     when others then dbms_sql.close_cursor( l_thecursor ); raise;
  end;