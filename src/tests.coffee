





############################################################################################################
CND                       = require 'cnd'
rpr                       = CND.rpr.bind CND
badge                     = 'MINGKWAI-NCR/tests'
log                       = CND.get_logger 'plain',     badge
info                      = CND.get_logger 'info',      badge
whisper                   = CND.get_logger 'whisper',   badge
alert                     = CND.get_logger 'alert',     badge
debug                     = CND.get_logger 'debug',     badge
warn                      = CND.get_logger 'warn',      badge
help                      = CND.get_logger 'help',      badge
urge                      = CND.get_logger 'urge',      badge
echo                      = CND.echo.bind CND
#...........................................................................................................
test                      = require 'guy-test'
{ step }                  = require 'coffeenode-suspend'
MKNCR                     = require './main'
ISL                       = MKNCR._ISL
u                         = MKNCR.unicode_isl

#===========================================================================================================
# HELPERS
#-----------------------------------------------------------------------------------------------------------
@_prune = ->
  for name, value of @
    continue if name.startsWith '_'
    delete @[ name ] unless name in include
  return null

#-----------------------------------------------------------------------------------------------------------
@_main = ->
  test @, 'timeout': 3000


#===========================================================================================================
# TESTS
#-----------------------------------------------------------------------------------------------------------
@[ "demo" ] = ( T ) ->
  #.........................................................................................................
  # for glyph in MKNCR.chrs_from_text "helo äöü你好𢕒𡕴𡕨𠤇𫠠𧑴𨒡《》【】&jzr#xe100;🖹"
  for glyph in MKNCR.chrs_from_text "《🖹"
    cid = MKNCR.as_cid glyph
    debug glyph, ISL.aggregate u, cid
    # cid_hex = hex cid
    # # debug glyph, cid_hex, find_id_text u, cid
    # descriptions = ISL.find_entries_with_all_points u, cid
    # urge glyph, cid_hex
    # for description in descriptions
    #   [ type, _, ] = ( description[ 'name' ] ? '???/' ).split ':'
    #   help ( CND.grey type + '/' ) + ( CND.steel 'interval' ) + ': ' + ( CND.yellow "#{hex description[ 'lo' ]}-#{hex description[ 'hi' ]}" )
    #   for key, value of description
    #     continue if key in [ 'lo', 'hi', 'id', ]
    #     help ( CND.grey type + '/' ) + ( CND.steel key ) + ': ' + ( CND.yellow value )
    # # urge glyph, cid_hex, JSON.stringify ISL.find_all_ids    u, cid
    # # info glyph, cid_hex, JSON.stringify ISL.find_any_ids    u, cid
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "aggregate" ] = ( T ) ->
  u         = MKNCR.unicode_isl
  ISL       = MKNCR._ISL
  probes_and_matchers = [
    ["q",{"tag":["assigned"],"rsg":"u-latn"}]
    ["里",{"tag":["assigned","ideograph","cjk","sim","sim/has-source","sim/is-target","sim/has-source/global","sim/is-target/global","sim/global"],"rsg":"u-cjk"}]
    ["䊷",{"tag":["assigned","ideograph","cjk"],"rsg":"u-cjk-xa"}]
    ["《",{"tag":["assigned","punctuation","cjk"],"rsg":"u-cjk-sym"}]
    ["🖹",{"tag":["assigned"]}]
    ["🛷",{"tag":["unassigned"]}]
    [887,{"tag":["assigned"],"rsg":"u-grek"}]
    [888,{"tag":["unassigned"],"rsg":"u-grek"}]
    [889,{"tag":["unassigned"],"rsg":"u-grek"}]
    [890,{"tag":["assigned"],"rsg":"u-grek"}]
    ]
  recipe  = { fallback: 'skip', fields: { 'tag': 'tag', 'rsg': 'assign', }, }
  for [ probe, matcher, ] in probes_and_matchers
    result = ISL.aggregate u, probe, recipe
    # debug '32771', JSON.stringify [ probe, result, ]
    T.eq result, matcher
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "SIMs, TeX formats" ] = ( T ) ->
  #.........................................................................................................
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
  #.........................................................................................................
  recipe =
    fallback: 'skip'
    fields:
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
  #.........................................................................................................
  recipe[ 'fields' ][ sim_tag ] = 'list' for sim_tag in sim_tags
  #.........................................................................................................
  # text  = '([Xqf]) ([里䊷䊷里]) ([Xqf])'
  # text  = 'q里䊷f'
  # text = '釒'
  # text = '龵⿸釒金𤴔丨亅㐅乂'
  probes_and_matchers = [
    ["龵",{"tag":["assigned","ideograph","cjk"],"rsg":"u-cjk","tex":{"block":"\\cn{}","codepoint":"{\\tfRaise{-0.1}\\cnxBabel{}龵}"}}]
    ["？",{"tag":["assigned","cjk"],"rsg":"u-halfull","tex":{"block":"\\cn{}"}}]
    ["⿸",{"tag":["assigned","cjk","idl"],"rsg":"u-cjk-idc","tex":{"block":"\\mktsRsgFb{}","codepoint":"{\\cnxJzr{}}"}}]
    ["釒",{"tag":["assigned","ideograph","cjk","sim","sim/has-target","sim/is-source","sim/has-target/components","sim/is-source/components","sim/components"],"rsg":"u-cjk","sim/target/components":["金"],"tex":{"block":"\\cn{}","codepoint":"{\\tfPush{0.4}釒}"}}]
    ["金",{"tag":["assigned","ideograph","cjk","sim/has-source/global","sim/is-target/global","sim/global","sim","sim/has-source","sim/is-target","sim/has-source/components","sim/is-target/components","sim/components"],"rsg":"u-cjk","sim/source/global":["金","⾦"],"sim/source/components":["釒"],"tex":{"block":"\\cn{}"}}]
    ["𤴔",{"tag":["assigned","ideograph","cjk","sim","sim/has-source","sim/is-target","sim/has-source/global","sim/is-target/global","sim/global"],"rsg":"u-cjk-xb","sim/source/global":["⺪"],"tex":{"block":"\\cnxb{}","codepoint":"{\\cnxBabel{}𤴔}"}}]
    ["丨",{"tag":["assigned","ideograph","cjk","sim","sim/has-source","sim/is-target","sim/has-source/global","sim/is-target/global","sim/global"],"rsg":"u-cjk","sim/source/global":["〡","⼁","㇑"],"tex":{"block":"\\cn{}"}}]
    ["亅",{"tag":["assigned","ideograph","cjk","sim","sim/has-source","sim/is-target","sim/has-source/global","sim/is-target/global","sim/global"],"rsg":"u-cjk","sim/source/global":["⼅","㇚"],"tex":{"block":"\\cn{}"}}]
    ["㐅",{"tag":["assigned","ideograph","cjk","sim/has-source","sim/is-target","sim/has-source/global","sim/is-target/global","sim/global","sim","sim/has-target","sim/is-source","sim/has-target/components","sim/is-source/components","sim/components"],"rsg":"u-cjk-xa","sim/source/global":["〤"],"sim/target/components":["乂"],"tex":{"block":"\\cnxa{}"}}]
    ["乂",{"tag":["assigned","ideograph","cjk","sim","sim/has-source","sim/is-target","sim/has-source/components","sim/is-target/components","sim/components"],"rsg":"u-cjk","sim/source/components":["㐅","乄"],"tex":{"block":"\\cn{}"}}]
    ]
  for [ probe, matcher, ] in probes_and_matchers
    description = ISL.aggregate u, probe, recipe
    # help '28107', matcher
    # warn '28107', description
    # debug '40223', JSON.stringify [ probe, description, ]; continue
    T.eq description, matcher
    # info probe
    ###
    urge '  tag:', ( description[ 'tag' ] ? [ '-/-' ] ).join ', '
    urge '  rsg:', description[ 'rsg' ]
    for sim_tag in sim_tags
      continue unless ( value = description[ sim_tag ] )?
      urge "  #{sim_tag}:", value
    urge '  blk:', description[ 'tex' ]?[ 'block'     ] ? '-/-'
    urge '  cp: ', description[ 'tex' ]?[ 'codepoint' ] ? '-/-'
    ###
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "descriptions (2)" ] = ( T ) ->
  probes_and_matchers = [
    ["⿲",["u",["assigned","cjk","idl"],{"block":"\\mktsRsgFb{}"}]]
    ["⿱",["u",["assigned","cjk","idl"],{"block":"\\mktsRsgFb{}","codepoint":"{\\cnxJzr{}}"}]]
    ["木",["u",["assigned","ideograph","cjk","sim","sim/has-source","sim/is-target","sim/has-source/global","sim/is-target/global","sim/global"],{"block":"\\cn{}"}]]
    ["&#x1233;",["u",["assigned"],{"block":"\\mktsRsgFb{}"}]]
    ["&#x1234;",["u",["assigned"],{"block":"\\mktsRsgFb{}"}]]
    ["&#x1235;",["u",["assigned"],{"block":"\\mktsRsgFb{}"}]]
    ["&morohashi#x1234;",["morohashi",["assigned","cjk"],undefined]]
    ["&#xe100;",["u",["assigned","pua","cjk"],{"block":"\\cnjzr{}"}]]
    ["&jzr#xe100;",["jzr",["assigned","cjk"],{"block":"\\cnjzr{}"}]]
    ["&jzr#xe19f;",["jzr",["assigned","cjk"],{"block":"\\cnjzr{}"}]]
    ]
  for [ probe, matcher, ] in probes_and_matchers
    description         = MKNCR.describe probe
    { csg, tag, tex, }  = description
    result              = [ csg, tag, tex, ]
    # urge JSON.stringify [ probe, result, ]
    # urge JSON.stringify [ probe, description, ]
    T.eq result, matcher
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "MojiKura get_set_of_CJK_ideograph_cids includes u-cjk-cmpi2" ] = ( T ) ->
  probes_and_matchers = [
    [ 'u-cjk-cmpi2/2f801',  '丸', [ 'cjk', 'ideograph', ], ] # mapped
    [ 'u-cjk-cmpi1/f9ba',   '了', [ 'cjk', 'ideograph', ], ] # mapped
    [ 'u-cjk-rad1/2f08',    '⼈', [ 'cjk', 'ideograph', ], ] # mapped
    [ 'u-cjk/4e0d',         '不', [ 'cjk', 'ideograph', ], ] # mapped
    [ 'u-cjk-cmpi1/f967',   '不', [ 'cjk', 'ideograph', ], ] # mapped
    [ 'u-cjk-cmpi1/fa0e',   '﨎', [ 'cjk', 'ideograph', ], ] # original
    [ 'u-hang-syl-ae00',    '글', [ 'cjk', 'korean', 'hangeul', ], ]
    [ 'u-cjk-hira-3072',    'ひ', [ 'cjk', 'japanese', 'kana', 'hiragana', ], ]
    [ 'u-cjk-sym/3001',     '、', [ 'cjk', 'punctuation',        ], ]
    [ 'u-cjk-sym/3004',     '〄', [ 'cjk', 'symbol',             ], ]
    [ 'u-cjk-sym/3005',     '々', [ 'cjk', 'ideograph',          ], ]
    [ 'u-cjk-sym/3008',     '〈', [ 'cjk', 'punctuation',        ], ]
    [ 'u-cjk-sym/3012',     '〒', [ 'cjk', 'symbol',             ], ]
    [ 'u-cjk-sym/3013',     '〓', [ 'cjk', 'ideograph', 'geta',  ], ]
    [ 'u-cjk-sym/3014',     '〔', [ 'cjk', 'punctuation',        ], ]
    [ 'u-cjk-sym/3020',     '〠', [ 'cjk', 'symbol',             ], ]
    [ 'u-cjk-sym/3021',     '〡', [ 'cjk', 'ideograph',          ], ]
    [ 'u-cjk-sym/302a',     '〪', [ 'cjk', 'punctuation',        ], ]
    [ 'u-cjk-sym/3031',     '〱', [ 'cjk', 'kana',               ], ]
    [ 'u-cjk-sym/3036',     '〶', [ 'cjk', 'symbol',             ], ]
    [ 'u-cjk-sym/3038',     '〸', [ 'cjk', 'ideograph',          ], ]
    [ 'u-cjk-sym/303d',     '〽', [ 'cjk', 'symbol',             ], ]

    ]
  #.........................................................................................................^
  ### from `mojikura/src/utilities.coffee`: ###
  L = {}
  L._set_from_facet = ( key, value ) ->
    R = new Set()
    for { lo, hi, } in MKNCR._ISL.find_entries MKNCR.unicode_isl, key, value
      R.add cid for cid in [ lo .. hi ]
    return R
  #.........................................................................................................^
  ### from `mojikura/src/utilities.coffee`: ###
  L.get_set_of_CJK_ideograph_cids = ->
    return R if ( R = L.get_set_of_CJK_ideograph_cids._R )?
    return L.get_set_of_CJK_ideograph_cids._R = L._set_from_facet 'tag', 'ideograph'
  #.........................................................................................................^
  ### TAINT should also check above methods include expected glyphs ###
  cjk_cids = L.get_set_of_CJK_ideograph_cids()
  for [ _, glyph, tags, ] in probes_and_matchers
    cid             = MKNCR.as_cid glyph
    description     = MKNCR.describe cid
    { fncr, }       = description
    glyph_tags      = description[ 'tag' ]
    glyph_tags_txt  = glyph_tags.join ', '
    for tag in tags
      if tag in glyph_tags
        T.ok true
        help "#{fncr} #{glyph}   has tag #{tag}: #{glyph_tags_txt}"
      else
        urge "#{fncr} #{glyph} lacks tag #{tag}: #{glyph_tags_txt}"
        T.fail "#{fncr} #{glyph}: lacks tag #{tag}"
    # debug ( cjk_cids.has cid ), JSON.stringify description
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "jzr_as_xncr" ] = ( T ) ->
  glyph       = "&jzr#xe234;"
  glyph_uchr  = MKNCR.jzr_as_uchr glyph
  glyph_r1    = MKNCR.jzr_as_xncr glyph
  glyph_r2    = MKNCR.jzr_as_xncr glyph_uchr
  # debug '32900', [ glyph, glyph_uchr, glyph_r1, glyph_r2, ]
  # debug '32900', MKNCR.jzr_as_xncr 'x'
  T.eq glyph_uchr, ''
  T.eq glyph_r1, '&jzr#xe234;'
  T.eq glyph_r2, '&jzr#xe234;'
  T.eq ( MKNCR.jzr_as_xncr 'x' ), 'x'

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


############################################################################################################
unless module.parent?
  # debug '0980', JSON.stringify ( Object.keys @ ), null, '  '
  include = [
    # "demo"
    "aggregate"
    "SIMs, TeX formats"
    "jzr_as_xncr"
    "descriptions (2)"
    "MojiKura get_set_of_CJK_ideograph_cids includes u-cjk-cmpi2"
    ]
  @_prune()
  @_main()

