(* Minidlna module for Augeas
 Author: Vladislav Lewin <vlewin@suse.de>
 Based on Postfix_Main lense from Free Ekanayaka <free@64studio.com>

 Reference:


*)

module Minidlna =

   autoload xfm

(************************************************************************
 *                           USEFUL PRIMITIVES
 *************************************************************************)

let eol        = Util.eol
(* let indent     = del /[ \t]*(\n[ \t]+)?/ " " *)
let indent  = Util.indent
let comment    = Util.comment
let empty      = Util.empty
(* let eq         = del /[ \t]*=/ " =" *)
let eq      = Util.del_str "="
let word       = /[A-Za-z0-9_.-]+/

(* The value of a parameter, after the '=' sign. Postfix allows that
 * lines are continued by starting continuation lines with spaces.
 * The definition needs to make sure we don't add indented comment lines
 * into values *)
let value =
  let chr = /[^# \t\n]/ in
  let any = /.*/ in
  let line = (chr . any* . chr | chr) in
  let lines = line . (/\n[ \t]+/ . line)* in
    store lines

(************************************************************************
 *                               ENTRIES
 *************************************************************************)

let entry     = [ key word . eq . (indent . value)? . eol ]

(************************************************************************
 *                                LENS
 *************************************************************************)

let lns        = (comment|empty|entry) *

let filter     = incl "/etc/minidlna.conf"
               . Util.stdexcl

let xfm        = transform lns filter
