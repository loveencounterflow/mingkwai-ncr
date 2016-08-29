

############################################################################################################
PATH                      = require 'path'
FS                        = require 'fs'
#...........................................................................................................
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'MINGKWAI-NCR'
log                       = CND.get_logger 'plain',     badge
debug                     = CND.get_logger 'debug',     badge
info                      = CND.get_logger 'info',      badge
urge                      = CND.get_logger 'urge',      badge
echo                      = CND.echo.bind CND
#...........................................................................................................
D                         = require 'pipedreams'
{ $
  $async }                = D
{ step }                  = require 'coffeenode-suspend'
#...........................................................................................................
NCR                       = require 'ncr'
module.exports            = MKNCR = NCR._copy_library 'xncr'
ISL                       = MKNCR._ISL
u                         = MKNCR.unicode_isl


#-----------------------------------------------------------------------------------------------------------
get_file_age = ( path, allow_missing = no ) ->
  try
    stats = FS.statSync path
  catch error
    throw error unless allow_missing and error[ 'code' ] is 'ENOENT'
    return -Infinity
  return +stats.mtime

#-----------------------------------------------------------------------------------------------------------
populate_isl = ( handler ) ->
  S =
    paths:
      cache:                PATH.resolve __dirname, '../data/isl-entries.json'
      mkts_options:         PATH.resolve __dirname, '../../mingkwai-typesetter/options.js'
      jizura_datasources:   PATH.resolve __dirname, '../../../jizura-datasources/data/flat-files/'
  S.paths.strokeorders = PATH.resolve S.paths.jizura_datasources, 'shape/shape-strokeorder-zhaziwubifa.txt'
  #.........................................................................................................
  source_age          = -Infinity
  source_age          = Math.max source_age, get_file_age S.paths.mkts_options
  source_age          = Math.max source_age, get_file_age S.paths.strokeorders
  cache_age           = get_file_age S.paths.cache, true
  must_rewrite_cache  = cache_age < source_age
  #.........................................................................................................
  if must_rewrite_cache then  rewrite_cache S, handler
  else                        read_cache    S, handler
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
read_cache = ( S, handler ) ->
  ISL.add u, entry for entry in require S.paths.cache
  handler()

#-----------------------------------------------------------------------------------------------------------
rewrite_cache = ( S, handler ) ->
  urge "rewriting cache"
  S.collector = []
  #.........................................................................................................
  step ( resume ) ->
    yield populate_isl_with_tex_formats  S, resume
    yield populate_isl_with_sims         S, resume
    FS.writeFileSync S.paths.cache, JSON.stringify S.collector, null, '  '
    ISL.add u, entry for entry in S.collector
    #.......................................................................................................
    handler()
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
populate_isl_with_tex_formats = ( S, handler ) ->
  #.........................................................................................................
  mkts_options              = require S.paths.mkts_options
  tex_command_by_rsgs       = mkts_options[ 'tex' ][ 'tex-command-by-rsgs' ]
  glyph_styles              = mkts_options[ 'tex' ][ 'glyph-styles'        ]
  #.........................................................................................................
  debug ( key for key of u[ 'indexes' ] )
  for rsg, block_command of tex_command_by_rsgs
    for entry in ISL.find_entries u, 'rsg', rsg
      ### Note: must push new entries to collector, cannot recycle existing ones here ###
      # target            = entry[ 'tex' ] ?= {}
      # target[ 'block' ] = block_style_as_tex block_command
      { lo, hi, tex, }  = entry
      tex              ?= {}
      tex[ 'block' ]    = block_style_as_tex block_command
    S.collector.push { lo, hi, tex, }
  #.........................................................................................................
  ### TAINT must resolve (X)NCRs ###
  for glyph, glyph_style of glyph_styles
    cid             = MKNCR.as_cid glyph
    glyph_style_tex = glyph_style_as_tex glyph, glyph_style
    S.collector.push { lo: cid, hi: cid, tex: { codepoint: glyph_style_tex, }, }
  #.........................................................................................................
  handler()

#-----------------------------------------------------------------------------------------------------------
populate_isl_with_sims = ( S, handler ) ->
  #.........................................................................................................
  $add_intervals = =>
    return $ ( record ) =>
      { source_glyph
        target_glyph  } = record
      # debug '3334', record
      source_cid        = MKNCR.as_cid record[ 'source_glyph' ]
      target_cid        = MKNCR.as_cid record[ 'target_glyph' ]
      otag              = record[ 'tag' ]
      mtag              = "sim/target/#{otag}"
      ctag              = "sim sim/has-target sim/is-source sim/has-target/#{otag} sim/is-source/#{otag} sim/#{otag}"
      # sim               = { "#{otag}": { target: target_glyph, }, }
      S.collector.push { lo: source_cid, hi: source_cid, "#{mtag}": target_glyph, tag: ctag, }
      mtag              = "sim/source/#{otag}"
      ctag              = "sim sim/has-source sim/is-target sim/has-source/#{otag} sim/is-target/#{otag} sim/#{otag}"
      # sim               = { "#{otag}": { source: source_glyph, }, }
      S.collector.push { lo: target_cid, hi: target_cid, "#{mtag}": source_glyph, tag: ctag, }
      return null
  #.........................................................................................................
  $collect_tags = =>
    tags = new Set
    return $ 'null', ( record ) =>
      if record? then tags.add record[ 'tag' ]
      else debug '3334', tags
      return null
  #.........................................................................................................
  SIMS            = require '../../jizura-db-feeder/lib/feed-sims'
  S1              = {}
  S1.db           = null
  S1.source_home  = S.paths.jizura_datasources
  input           = SIMS.new_sim_readstream S1, filter: yes
  #.........................................................................................................
  input
    .pipe $add_intervals()
    .pipe $ 'finish', handler
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
block_style_as_tex = ( block_style ) -> "\\#{block_style}"

#-----------------------------------------------------------------------------------------------------------
glyph_style_as_tex = ( glyph, glyph_style ) ->
  ### NOTE this code replaces parts of `tex-writer-typofix._style_chr` ###
  #.........................................................................................................
  ### TAINT using `prPushRaise` here in place of `tfPushRaise` because it gives better
  results ###
  use_tfpushraise = no
  #.........................................................................................................
  R         = []
  R.push "{"
  # R.push "\\cn" if is_cjk
  rpl_push  = glyph_style[ 'push'   ] ? null
  rpl_raise = glyph_style[ 'raise'  ] ? null
  rpl_chr   = glyph_style[ 'glyph'  ] ? glyph
  rpl_cmd   = glyph_style[ 'cmd'    ] ? null
  # rpl_cmd   = glyph_style[ 'cmd'    ] ? rsg_command
  # rpl_cmd   = null if rpl_cmd is 'cn'
  #.........................................................................................................
  if use_tfpushraise
    if      rpl_push? and rpl_raise?  then R.push "\\prPushRaise{#{rpl_push}}{#{rpl_raise}}{"
    else if rpl_push?                 then R.push "\\prPush{#{rpl_push}}{"
    else if               rpl_raise?  then R.push "\\prRaise{#{rpl_raise}}{"
  #.........................................................................................................
  else
    if      rpl_push? and rpl_raise?  then R.push "\\tfPushRaise{#{rpl_push}}{#{rpl_raise}}"
    else if rpl_push?                 then R.push "\\tfPush{#{rpl_push}}"
    else if               rpl_raise?  then R.push "\\tfRaise{#{rpl_raise}}"
  #.........................................................................................................
  if rpl_cmd?                       then R.push "\\#{rpl_cmd}{}"
  R.push rpl_chr
  R.push "}" if use_tfpushraise and ( rpl_push? or rpl_raise? )
  R.push "}"
  R = R.join ''
  return R

#-----------------------------------------------------------------------------------------------------------
demo = ( handler ) ->
  step ( resume ) =>
    yield populate_isl resume
    ### TAINT tags should be collected during SIM reading ###
    sim_tags = [
      'sim/source/global'
      'sim/source/components'
      'sim/source/components/search'
      'sim/source/false-identity'
      'sim/target/global'
      'sim/target/components'
      'sim/target/components/search'
      'sim/target/false-identity'
      ]
    #.......................................................................................................
    reducers =
      '*':  'skip'
      tag:  'tag'
      rsg:  'assign'
      # sim:  ( values, context ) ->
      #   ### TAINT should be a standard reducer ###
      #   debug '7701', values
      #   R = {}
      #   for value in values
      #     for name, sub_value of value
      #       R[ name ] = sub_value
      #   return R
      tex:  ( values, context ) ->
        ### TAINT should be a standard reducer ###
        R = {}
        for value in values
          for name, sub_value of value
            R[ name ] = sub_value
        return R
    #.......................................................................................................
    reducers[ sim_tag ] = 'list' for sim_tag in sim_tags
    aggregate           = _get_aggregate MKNCR, reducers
    #.......................................................................................................
    # text  = '([Xqf]) ([里䊷䊷里]) ([Xqf])'
    # text  = 'q里䊷f'
    text = '釒'
    text = '龵⿸釒金𤴔丨亅㐅乂'
    for glyph in Array.from text
      description = aggregate glyph
      info glyph
      urge '  tag:', ( description[ 'tag' ] ? [ '-/-' ] ).join ', '
      urge '  rsg:', description[ 'rsg' ]
      # if ( sim = description[ 'sim' ] )?
      #   for sim_tag, value of sim
      #     urge "  sim:#{sim_tag}: #{rpr value}"
      # else
      #   urge '  sim:', '-/-'
      for sim_tag in sim_tags
        continue unless ( value = description[ sim_tag ] )?
        urge "  #{sim_tag}:", value
      urge '  blk:', description[ 'tex' ]?[ 'block'     ] ? '-/-'
      urge '  cp: ', description[ 'tex' ]?[ 'codepoint' ] ? '-/-'
    #.......................................................................................................
    handler()
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
demo_2 = ->
  #.........................................................................................................
  # tag = 'sim/is-target/global'
  tags = [
    'global'
    'components'
    'components/search'
    'false-identity'
    ]
  for tag in tags
    echo tag
    search_tag  = "sim/is-target/#{tag}"
    entry_tag   = "sim/source/#{tag}"
    for entry in MKNCR._ISL.find_entries u, 'tag', search_tag
      ### Silently assuming that all relevant entries represent single-character intervals ###
      target_glyph_info = MKNCR.analyze ( cid = entry[ 'lo' ] )
      target_glyph      = target_glyph_info[ 'uchr' ]
      target_fncr       = target_glyph_info[ 'fncr' ]
      source_glyph      = entry[ entry_tag ]
      source_glyph_info = MKNCR.analyze source_glyph
      source_fncr       = source_glyph_info[ 'fncr' ]
      echo target_fncr, target_glyph, '<-', source_fncr, source_glyph
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
_get_aggregate = ( ncr, reducers ) ->
  cache = {}
  return ( glyph ) =>
    return R if ( R = cache[ glyph ] )?
    return cache[ glyph ] = ncr._ISL.aggregate ncr.unicode_isl, glyph, reducers





############################################################################################################
unless module.parent?
  demo ( error ) ->
    throw error if error?


