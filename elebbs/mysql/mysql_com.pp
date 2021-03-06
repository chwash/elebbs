unit mysql_com;
{$mode objfpc}
interface

{
  Automatically converted by H2Pas 0.99.15 from mysql_com.ph
  The following command line parameters were used:
    -p
    -D
    -l
    mysqlclient
    mysql_com.ph
}

  const
  {$ifdef win32}
    External_library='libmysql'; {Setup as you need}
  {$else}
    External_library='mysqlclient'; {Setup as you need}
  {$endif}

  { Pointers to basic pascal types, inserted by h2pas conversion program.}
  Type
    PLongint  = ^Longint;
    PSmallInt = ^SmallInt;
    PByte     = ^Byte;
    PWord     = ^Word;
    PDWord    = ^DWord;
    PDouble   = ^Double;

{ Extra manually added types }
    PVIO = Pointer;
    My_socket = longint;
    my_bool = byte;
    pppchar = ^PPChar;
    gptr = Pointer;


{$PACKRECORDS C}

  { Copyright (C) 2000 MySQL AB

     This program is free software; you can redistribute it and/or modify
     it under the terms of the GNU General Public License as published by
     the Free Software Foundation; either version 2 of the License, or
     (at your option) any later version.

     This program is distributed in the hope that it will be useful,
     but WITHOUT ANY WARRANTY; without even the implied warranty of
     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
     GNU General Public License for more details.

     You should have received a copy of the GNU General Public License
     along with this program; if not, write to the Free Software
     Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA  }
  {
     Common definition between mysql server & client
   }
  { Field/table name length  }

  const
     NAME_LEN = 64;
     HOSTNAME_LENGTH = 60;
     USERNAME_LENGTH = 16;
     SERVER_VERSION_LENGTH = 60;
     LOCAL_HOST = 'localhost';
     LOCAL_HOST_NAMEDPIPE = '.';

  type
     enum_server_command = (COM_SLEEP,COM_QUIT,COM_INIT_DB,COM_QUERY,
       COM_FIELD_LIST,COM_CREATE_DB,COM_DROP_DB,
       COM_REFRESH,COM_SHUTDOWN,COM_STATISTICS,
       COM_PROCESS_INFO,COM_CONNECT,COM_PROCESS_KILL,
       COM_DEBUG,COM_PING,COM_TIME,COM_DELAYED_INSERT,
       COM_CHANGE_USER,COM_BINLOG_DUMP,COM_TABLE_DUMP,
       COM_CONNECT_OUT,COM_REGISTER_SLAVE);

  { Field can't be NULL  }

  const
     NOT_NULL_FLAG = 1;
  { Field is part of a primary key  }
     PRI_KEY_FLAG = 2;
  { Field is part of a unique key  }
     UNIQUE_KEY_FLAG = 4;
  { Field is part of a key  }
     MULTIPLE_KEY_FLAG = 8;
  { Field is a blob  }
     BLOB_FLAG = 16;
  { Field is unsigned  }
     UNSIGNED_FLAG = 32;
  { Field is zerofill  }
     ZEROFILL_FLAG = 64;
     BINARY_FLAG = 128;
  { The following are only sent to new clients  }
  { field is an enum  }
     ENUM_FLAG = 256;
  { field is a autoincrement field  }
     AUTO_INCREMENT_FLAG = 512;
  { Field is a timestamp  }
     TIMESTAMP_FLAG = 1024;
  { field is a set  }
     SET_FLAG = 2048;
  { Field is num (for clients)  }
     NUM_FLAG = 32768;
  { Intern; Part of some key  }
     PART_KEY_FLAG = 16384;
  { Intern: Group field  }
     GROUP_FLAG = 32768;
  { Intern: Used by sql_yacc  }
     UNIQUE_FLAG = 65536;
  { Refresh grant tables  }
     REFRESH_GRANT = 1;
  { Start on new log file  }
     REFRESH_LOG = 2;
  { close all tables  }
     REFRESH_TABLES = 4;
  { Flush host cache  }
     REFRESH_HOSTS = 8;
  { Flush status variables  }
     REFRESH_STATUS = 16;
  { Flush status variables  }
     REFRESH_THREADS = 32;
  { Reset master info and restart slave
                                           thread  }
     REFRESH_SLAVE = 64;
  { Remove all bin logs in the index
                                           and truncate the index  }
     REFRESH_MASTER = 128;
  { The following can't be set with mysql_refresh()  }
  { Lock tables for read  }
     REFRESH_READ_LOCK = 16384;
  { Intern flag  }
     REFRESH_FAST = 32768;
  { RESET (remove all queries) from query cache  }
     REFRESH_QUERY_CACHE = 65536;
  { pack query cache  }
     REFRESH_QUERY_CACHE_FREE = $20000;
     REFRESH_DES_KEY_FILE = $40000;
  { new more secure passwords  }
     CLIENT_LONG_PASSWORD = 1;
  { Found instead of affected rows  }
     CLIENT_FOUND_ROWS = 2;
  { Get all column flags  }
     CLIENT_LONG_FLAG = 4;
  { One can specify db on connect  }
     CLIENT_CONNECT_WITH_DB = 8;
  { Don't allow database.table.column  }
     CLIENT_NO_SCHEMA = 16;
  { Can use compression protocol  }
     CLIENT_COMPRESS = 32;
  { Odbc client  }
     CLIENT_ODBC = 64;
  { Can use LOAD DATA LOCAL  }
     CLIENT_LOCAL_FILES = 128;
  { Ignore spaces before '('  }
     CLIENT_IGNORE_SPACE = 256;
  { Support the mysql_change_user()  }
     CLIENT_CHANGE_USER = 512;
  { This is an interactive client  }
     CLIENT_INTERACTIVE = 1024;
  { Switch to SSL after handshake  }
     CLIENT_SSL = 2048;
  { IGNORE sigpipes  }
     CLIENT_IGNORE_SIGPIPE = 4096;
  { Client knows about transactions  }
     CLIENT_TRANSACTIONS = 8192;
  { Transaction has started  }
     SERVER_STATUS_IN_TRANS = 1;
  { Server in auto_commit mode  }
     SERVER_STATUS_AUTOCOMMIT = 2;
     MYSQL_ERRMSG_SIZE = 200;
  { Timeout on read  }
     NET_READ_TIMEOUT = 30;
  { Timeout on write  }
     NET_WRITE_TIMEOUT = 60;
  {
  #define NET_WAIT_TIMEOUT      (8 60 60)
   }
  { Wait for new query  }
  {
  struct st_vio;                                        // Only C
  typedef struct st_vio Vio;
   }
  { Default width for blob }
     MAX_BLOB_WIDTH = 8192;
  { For Perl DBI/dbd  }
  {
      The following variable is set if we are doing several queries in one
      command ( as in LOAD TABLE ... FROM MASTER ),
      and do not want to confuse the client with OK at the wrong time
     }

  type

     Pst_net = ^st_net;
     st_net = record
          vio : PVio;
          buff : Pbyte;
          buff_end : Pbyte;
          write_pos : Pbyte;
          read_pos : Pbyte;
          fd : my_socket;
          max_packet : dword;
          fcntl : longint;
          last_errno : dword;
          timeout : dword;
          pkt_nr : dword;
          compress_pkt_nr : dword;
          last_error : array[0..(MYSQL_ERRMSG_SIZE)-1] of char;
          error : byte;
          return_errno : my_bool;
          compress : my_bool;
          remain_in_buf : dword;
          length : dword;
          buf_length : dword;
          where_b : dword;
          return_status : Pdword;
          reading_or_writing : byte;
          save_char : char;
          no_send_ok : my_bool;
          query_cache_query : gptr;
       end;
     NET = st_net;
     PNET = ^NET;
  { was #define dname def_expr }
  function packet_error : longint;
      { return type might be wrong }


  type
     enum_field_types = (FIELD_TYPE_DECIMAL,FIELD_TYPE_TINY,FIELD_TYPE_SHORT,
       FIELD_TYPE_LONG,FIELD_TYPE_FLOAT,FIELD_TYPE_DOUBLE,
       FIELD_TYPE_NULL,FIELD_TYPE_TIMESTAMP,
       FIELD_TYPE_LONGLONG,FIELD_TYPE_INT24,
       FIELD_TYPE_DATE,FIELD_TYPE_TIME,FIELD_TYPE_DATETIME,
       FIELD_TYPE_YEAR,FIELD_TYPE_NEWDATE,FIELD_TYPE_ENUM := 247,
       FIELD_TYPE_SET := 248,FIELD_TYPE_TINY_BLOB := 249,
       FIELD_TYPE_MEDIUM_BLOB := 250,FIELD_TYPE_LONG_BLOB := 251,
       FIELD_TYPE_BLOB := 252,FIELD_TYPE_VAR_STRING := 253,
       FIELD_TYPE_STRING := 254);

  { For compability  }

  const
     FIELD_TYPE_CHAR = FIELD_TYPE_TINY;
  { For compability  }
     FIELD_TYPE_INTERVAL = FIELD_TYPE_ENUM;
  {
  #define net_new_transaction(net) ((net)->pkt_nr=0)
   }

//    var
//       max_allowed_packet : dword;cvar;external;
//       net_buffer_length : dword;cvar;external;

//  function my_net_init(net:PNET; vio:PVio):longint;{$ifdef win32}stdcall; {$else} cdecl; {$endif}external External_library name 'my_net_init';

//  procedure net_end(net:PNET);{$ifdef win32}stdcall; {$else} cdecl; {$endif}external External_library name 'net_end';

//  procedure net_clear(net:PNET);{$ifdef win32}stdcall; {$else} cdecl; {$endif}external External_library name 'net_clear';

//  function net_flush(net:PNET):longint;{$ifdef win32}stdcall; {$else} cdecl; {$endif}external External_library name 'net_flush';

(* Const before type ignored *)
//  function my_net_write(net:PNET; packet:Pchar; len:dword):longint;{$ifdef win32}stdcall; {$else} cdecl; {$endif}external External_library name 'my_net_write';

(* Const before type ignored *)
//  function net_write_command(net:PNET; command:byte; packet:Pchar; len:dword):longint;{$ifdef win32}stdcall; {$else} cdecl; {$endif}external External_library name 'net_write_command';

(* Const before type ignored *)
//  function net_real_write(net:PNET; packet:Pchar; len:dword):longint;{$ifdef win32}stdcall; {$else} cdecl; {$endif}external External_library name 'net_real_write';

//  function my_net_read(net:PNET):dword;{$ifdef win32}stdcall; {$else} cdecl; {$endif}external External_library name 'my_net_read';

  { The following function is not meant for normal usage  }
  {
  struct sockaddr;
  int my_connect(my_socket s, const struct sockaddr  name, unsigned int namelen,
               unsigned int timeout);
   }

  type
     Prand_struct = ^rand_struct;
     rand_struct = record
          seed1 : dword;
          seed2 : dword;
          max_value : dword;
          max_value_dbl : double;
       end;

  { The following is for user defined functions  }
     Item_result = (STRING_RESULT,REAL_RESULT,INT_RESULT
       );
  pitem_result = ^item_result;

  { Number of arguments  }
  { Pointer to item_results  }
  { Pointer to argument  }
  { Length of string arguments  }
  { Set to 1 for all maybe_null args  }

     Pst_udf_args = ^st_udf_args;
     st_udf_args = record
          arg_count : dword;
          arg_type : PItem_result;
          args : ^Pchar;
          lengths : Pdword;
          maybe_null : Pchar;
       end;
     UDF_ARGS = st_udf_args;
     PUDF_ARGS = ^UDF_ARGS;
  { This holds information about the result  }
  { 1 if function can return NULL  }
  { for real functions  }
  { For string functions  }
  { free pointer for function data  }
  { 0 if result is independent of arguments  }

     Pst_udf_init = ^st_udf_init;
     st_udf_init = record
          maybe_null : my_bool;
          decimals : dword;
          max_length : dword;
          ptr : Pchar;
          const_item : my_bool;
       end;
     UDF_INIT = st_udf_init;
     PUDF_INIT = ^UDF_INIT;
  { Constants when using compression  }
  { standard header size  }

  const
     NET_HEADER_SIZE = 4;
  { compression header extra size  }
     COMP_HEADER_SIZE = 3;
  { Prototypes to password functions  }

//  procedure randominit(_para1:Prand_struct; seed1:dword; seed2:dword);{$ifdef win32}stdcall; {$else} cdecl; {$endif}external External_library name 'randominit';

//  function rnd(_para1:Prand_struct):double;{$ifdef win32}stdcall; {$else} cdecl; {$endif}external External_library name 'rnd';

(* Const before type ignored *)
//  procedure make_scrambled_password(_to:Pchar; password:Pchar);{$ifdef win32}stdcall; {$else} cdecl; {$endif}external External_library name 'make_scrambled_password';

(* Const before type ignored *)
//  procedure get_salt_from_password(res:Pdword; password:Pchar);{$ifdef win32}stdcall; {$else} cdecl; {$endif}external External_library name 'get_salt_from_password';

//  procedure make_password_from_salt(_to:Pchar; hash_res:Pdword);{$ifdef win32}stdcall; {$else} cdecl; {$endif}external External_library name 'make_password_from_salt';

(* Const before type ignored *)
(* Const before type ignored *)
//  function scramble(_to:Pchar; message:Pchar; password:Pchar; old_ver:my_bool):Pchar;{$ifdef win32}stdcall; {$else} cdecl; {$endif}external External_library name 'scramble';

(* Const before type ignored *)
(* Const before type ignored *)
//  function check_scramble(_para1:Pchar; message:Pchar; salt:Pdword; old_ver:my_bool):my_bool;{$ifdef win32}stdcall; {$else} cdecl; {$endif}external External_library name 'check_scramble';

//  function get_tty_password(opt_message:Pchar):Pchar;{$ifdef win32}stdcall; {$else} cdecl; {$endif}external External_library name 'get_tty_password';

(* Const before type ignored *)
//  procedure hash_password(result:Pdword; password:Pchar);{$ifdef win32}stdcall; {$else} cdecl; {$endif}external External_library name 'hash_password';

  { Some other useful functions  }
//  procedure my_init;{$ifdef win32}stdcall; {$else} cdecl; {$endif}external External_library name 'my_init';

(* Const before type ignored *)
(* Const before type ignored *)
//  procedure load_defaults(conf_file:Pchar; groups:PPchar; argc:Plongint; argv:PPPchar);{$ifdef win32}stdcall; {$else} cdecl; {$endif}external External_library name 'load_defaults';

//  function my_thread_init:my_bool;{$ifdef win32}stdcall; {$else} cdecl; {$endif}external External_library name 'my_thread_init';

//  procedure my_thread_end;{$ifdef win32}stdcall; {$else} cdecl; {$endif}external External_library name 'my_thread_end';

  { For net_store_length  }
  { was #define dname def_expr }
//  function NULL_LENGTH : dword;


implementation

  { was #define dname def_expr }
  function packet_error : longint;
      { return type might be wrong }
      begin
         packet_error:= not (dword(0));
      end;

  { was #define dname def_expr }
  function NULL_LENGTH : dword;
      begin
//         NULL_LENGTH:=dword( not (0));
      end;


end.
