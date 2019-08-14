import Transformer from require "moonscript.transform.transformer"
import build, ntype, smart_node from require "moonscript.types"

import NameProxy from require "moonscript.transform.names"
import Accumulator, default_accumulator from require "moonscript.transform.accumulator"
import lua_keywords from require "moonscript.data"

import Run, transform_last_stm, implicitly_return, chain_is_stub from require "moonscript.transform.statements"
parse_str = require("moonscript.parse").string

import construct_comprehension from require "moonscript.transform.comprehension"

import insert from table
import unpack, dump, dumpsimple from require "moonscript.util"
-- Reverses table
reverse = (t) ->
  nt = {}
  for i = #t, 1, -1
    nt[#t-i+1] = t[i] 
  nt

Transformer {
  for: default_accumulator
  while: default_accumulator
  foreach: default_accumulator

  do: (node) =>
    build.block_exp node[2]

  decorated: (node) =>
    @transform.statement node

  class: (node) =>
    build.block_exp { node }

  string: (node) =>
    delim = node[2]

    convert_part = (part) ->
      if type(part) == "string" or part == nil
        {"string", delim, part or ""}
      else
        build.chain { base: "tostring", {"call", {part[2]}} }

    -- reduced to single item
    if #node <= 3
      return if type(node[3]) == "string"
        node
      else
        convert_part node[3]

    e = {"exp", convert_part node[3]}

    for i=4, #node
      insert e, ".."
      insert e, convert_part node[i]
    e

  comprehension: (node) =>
    a = Accumulator!
    node = @transform.statement node, (exp) ->
      a\mutate_body {exp}
    a\wrap node

  tblcomprehension: (node) =>
    explist, clauses = unpack node, 2
    key_exp, value_exp = unpack explist

    accum = NameProxy "tbl"

    inner = if value_exp
      dest = build.chain { base: accum, {"index", key_exp} }
      { build.assign_one dest, value_exp }
    else
      -- If we only have single expression then
      -- unpack the result into key and value
      key_name, val_name = NameProxy"key", NameProxy"val"
      dest = build.chain { base: accum, {"index", key_name} }
      {
        build.assign names: {key_name, val_name}, values: {key_exp}
        build.assign_one dest, val_name
      }

    build.block_exp {
      build.assign_one accum, build.table!
      construct_comprehension inner, clauses
      accum
    }

  fndef: (node) =>
    smart_node node
    node.body = transform_last_stm node.body, implicitly_return self
    node.body = {
      Run => @listen "varargs", -> -- capture event
      unpack node.body
    }

    node

  if: (node) =>
    build.block_exp { node }

  unless: (node) =>
    build.block_exp { node }

  with: (node) =>
    build.block_exp { node }

  switch: (node) =>
    build.block_exp { node }

  pipe: (node) =>
    -- For every value in the pipe
    z = node[2]
    for v in *node[2,]
      is_call = false
      
      -- Does have call?
      for th in *v
        if th[1] and th[1] == "call"
          is_call = true
      
      -- If this is a simple pipe aka. "10 |> z"
      if (v[1] == "ref" or (v[1] == "chain" and v[2][1] == "ref" and not is_call)) and _index_0 > 2
        previous_node = node[_index_0-1]
        zy = z
        z = {"chain"}
        for vz in *v[2,]
          z[#z+1] = vz
        z[#z+1] = {"call", {zy}}
        --print dump z
      -- Is a call pipe aka. "'thing' |> string.sub(3, 3)"
      elseif _index_0 > 2
        previous_node = node[_index_0-1]
        zy = z
        z = {"chain"}
        for vz in *v[2,]
          break if vz[1] and vz[1] == "call"
          z[#z+1] = vz

        call = nil
        -- Find call
        for th in *v
          if th[1] and th[1] == "call"
            call = th

        args = {zy}
        for arg in *call[2]
          args[#args+1] = arg
        z[#z+1] = {"call", args}
    z

  quote: (node) =>
    dumpsimple node[2][1], @

  -- pull out colon chain
  chain: (node) =>

    if @macros\is_macro node[2][2]
      mname = node[2][2]
      macro = @macros\get_macro mname
      
      z = with @block @line "return function(builder, node)" 
        \stms macro

      rend = z\render(@lines!)\flatten!
      code = ""
      for f in *rend
        code ..= f
      print code
      
      builder_functions = {
        literal: (x) ->
          z = parse_str x
          @transform.statement z[1] if z

        value: (x) ->
          if ntype(x) == "string"
            return "\"#{x[3]}\""
          x[2]

        dump: (x) ->
          print dump x
      }

      builder = setmetatable {}, {
        __index: (t, k) ->
          unless builder_functions[k]
            (...) ->
              return {k, unpack {...}}
          else
            builder_functions[k]
      }
      print loadstring(code)
      mfun = loadstring(code)!
      return mfun builder, node[#node][2]
      

    -- escape lua keywords used in dot accessors
    for i=2,#node
      part = node[i]
      if ntype(part) == "dot" and lua_keywords[part[2]]
        node[i] = { "index", {"string", '"', part[2]} }

    if ntype(node[2]) == "string"
      -- add parens if callee is raw string
      node[2] = {"parens", node[2] }

    if chain_is_stub node
      base_name = NameProxy "base"
      fn_name = NameProxy "fn"
      colon = table.remove node

      is_super = ntype(node[2]) == "ref" and node[2][2] == "super"
      build.block_exp {
        build.assign {
          names: {base_name}
          values: {node}
        }

        build.assign {
          names: {fn_name}
          values: {
            build.chain { base: base_name, {"dot", colon[2]} }
          }
        }

        build.fndef {
          args: {{"..."}}
          body: {
            build.chain {
              base: fn_name, {"call", {is_super and "self" or base_name, "..."}}
            }
          }
        }
      }

  block_exp: (node) =>
    body = unpack node, 2

    fn = nil
    arg_list = {}

    fn = smart_node build.fndef body: {
      Run =>
        @listen "varargs", ->
          insert arg_list, "..."
          insert fn.args, {"..."}
          @unlisten "varargs"

      unpack body
    }

    build.chain { base: {"parens", fn}, {"call", arg_list} }
}

