
--POINT without id
select g,encode(ST_AsTWKB(g::geometry,p),'hex') from
(select 'POINT(1 1)'::text g, 0 p) foo;
--POINT with id
select g,encode(ST_AsTWKB(g::geometry,p),'hex') from
(select 'POINT(1 1)'::text g, 0 p) foo;
--POINT with multibyte values and negative values
select g,encode(ST_AsTWKB(g::geometry,p),'hex') from
(select 'POINT(78 -78)'::text g, 0 p) foo;
--POINT rounding to 2 decimals in coordinates
select g,encode(ST_AsTWKB(g::geometry,p),'hex') from
(select 'POINT(123.456789 987.654321)'::text g, 2 p) foo;

--LINESTRING
select g,encode(ST_AsTWKB(g::geometry,p),'hex') from
(select 'LINESTRING(120 10, -50 20, 300 -2)'::text g, 0 p) foo;
select g,encode(ST_AsTWKB(g::geometry,p),'hex') from
(select 'LINESTRING(120 10, -50 20, 300 -2)'::text g, 2 p) foo;
select g,encode(ST_AsTWKB(g::geometry,p),'hex') from
(select 'LINESTRING(120.54 10.78, -50.2 20.878, 300.789 -21)'::text g, 0 p) foo;

--POLYGON
select g,encode(ST_AsTWKB(g::geometry,p),'hex') from
(select 'POLYGON((1 1, 1 2, 2 2, 2 1, 1 1))'::text g, 0 p) foo;
--POLYGON with hole
select g,encode(ST_AsTWKB(g::geometry,p),'hex') from
(select 'POLYGON((1 1, 1 20, 20 20, 20 1, 1 1),(3 3,3 4, 4 4,4 3,3 3))'::text g, 0 p) foo;

--MULTIPOINT
select g,encode(ST_AsTWKB(g::geometry,p),'hex') from
(select 'MULTIPOINT((1 1),(2 2))'::text g, 0 p) foo;

--MULTILINESTRING
select g,encode(ST_AsTWKB(g::geometry,p),'hex') from
(select 'MULTILINESTRING((1 1,1 2,2 2),(3 3,3 4,4 4))'::text g, 0 p) foo;

--MULTIPOLYGON
select g,encode(ST_AsTWKB(g::geometry,p),'hex') from
(select 'MULTIPOLYGON(((1 1, 1 2, 2 2, 2 1, 1 1)),((3 3,3 4,4 4,4 3,3 3)))'::text g, 0 p) foo;
--MULTIPOLYGON with hole
select g,encode(ST_AsTWKB(g::geometry,p),'hex') from
(select 'MULTIPOLYGON(((1 1, 1 20, 20 20, 20 1, 1 1),(3 3,3 4, 4 4,4 3,3 3)),((-1 1, -1 20, -20 20, -20 1, -1 1),(-3 3,-3 4, -4 4,-4 3,-3 3)))'::text g, 0 p) foo;

--GEOMETRYCOLLECTION
select st_astext(st_collect(g::geometry)), encode(ST_AsTWKB(ST_Collect(g::geometry),0),'hex') from
(
select 'POINT(1 1)'::text g
union all
select 'LINESTRING(2 2, 3 3)'::text g
order by g desc -- Force order to get consistent results with parallel plans
) foo;

select st_astext(st_collect(g::geometry)), encode(ST_AsTWKB(ST_Collect(g::geometry),0),'hex') from
(
select 'MULTIPOINT((1 1),(2 2))'::text g
union all
select 'POINT(78 -78)'::text g
union all
select 'POLYGON((1 1, 1 2, 2 2, 2 1, 1 1))'::text g
order by g -- Force order to get consistent results with parallel plans
) foo;

--GEOMETRYCOLLECTION with bounding box ref #3187
select encode(st_astwkb(st_collect('point(4 1)'::geometry,'linestring(1 1, 0 3)'::geometry),0,0,0,false,true),'hex');

-- LARGE geometry
select 'large geometry', encode(st_astwkb('MULTIPOLYGON(((700884.902707907 6594484.28442262,700888.07161072 6594470.32471228,700929.132888923 6594464.82349185,700943.080475651 6594468.99211503,700962.172157371 6594461.22471636,700976.119744629 6594465.39333965,700985.959330685 6594478.51094871,700982.729805053 6594497.46926236,700981.269354425 6594535.44651171,700974.162191361 6594544.35912339,700962.813656264 6594573.21764363,700945.648666967 6594587.00761089,700937.614530775 6594589.90977536,700937.529658826 6594596.90781752,700954.258163453 6594619.1077824,700953.100823312 6594632.09202203,700976.815245098 6594655.37658072,700992.738022996 6594661.56889711,700999.784564162 6594657.65488811,701000.90553088 6594647.66980898,700988.127409188 6594629.51722228,700996.404037829 6594606.62065054,701027.43174373 6594603.9973514,701061.507110362 6594597.41154408,701087.669586373 6594583.73069639,701105.713053409 6594579.95005653,701118.61242347 6594588.10543991,701125.525595072 6594595.18835553,701135.340931529 6594610.30540927,701130.002839808 6594638.23696095,701131.771912758 6594657.25590016,701144.756155006 6594658.41324112,701148.924782151 6594644.46565212,701149.215773044 6594620.47235906,701153.420773398 6594603.52560814,701161.661029394 6594583.62819364,701171.840103446 6594568.75363072,701187.969002765 6594557.95069703,701205.061249284 6594550.15904932,701250.242670362 6594534.70912272,701272.297147804 6594529.97725867,701290.376991948 6594523.19745496,701295.411969023 6594520.25891535,701294.48499531 6594514.24846656,701279.525558209 6594511.06743703,701269.491977809 6594513.94535417,701264.444876405 6594517.88361441,701238.318769561 6594528.56530461,701203.207302361 6594538.13815293,701187.114776566 6594545.94192539,701175.069631435 6594549.7953134,701158.916483364 6594562.59768821,701142.581466952 6594590.39587067,701131.523918212 6594595.261103,701115.722383011 6594579.07158162,701115.855753089 6594568.074656,701117.964314987 6594559.10142047,701127.046671389 6594552.21249764,701137.177246451 6594541.33681704,701143.478682294 6594516.41655055,701153.682003984 6594499.542546,701155.826938685 6594487.57014822,701154.924213759 6594479.56025929,701143.012438235 6594472.41672207,701127.992381276 6594474.23429652,701106.792134741 6594490.97493185,701098.636752674 6594503.87430262,701088.372809105 6594525.74690853,701096.322075 6594529.84278648,701100.223960915 6594537.88904845,701112.026614593 6594554.03007072,701112.917214279 6594563.03967982,701108.797086798 6594572.98838669,701092.71668702 6594579.79243727,701083.70707815 6594580.68303672,701078.732724908 6594578.62297299,701076.842404931 6594569.60123968,701074.085734224 6594549.57045675,701066.366834262 6594526.47989006,701042.713029022 6594498.19673006,701034.763763437 6594494.10085265,701025.887524187 6594483.99452838,701026.081515193 6594467.99900173,701041.150068125 6594462.18254557,701052.171241807 6594460.31647335,701069.287733725 6594450.52538388,701111.494233561 6594433.03964,701130.476799132 6594434.26972406,701143.400419772 6594440.42566453,701157.481378388 6594433.59736225,701168.769289935 6594409.73743675,701174.022504426 6594388.80392631,701180.069325355 6594384.87779003,701197.076699956 6594384.08418329,701199.978866999 6594392.11832126,701204.928972663 6594396.17782551,701211.999763175 6594390.26437226,701250.649386155 6594418.72940089,701252.551832363 6594426.75141505,701250.394773775 6594439.72353496,701252.200224396 6594455.74331452,701263.063783043 6594466.87361074,701274.109208371 6594463.00809683,701276.217769663 6594454.03485944,701272.376504353 6594440.98999271,701263.597257406 6594422.88590067,701257.805047825 6594405.81790278,701254.133522779 6594378.77694703,701249.328908743 6594362.72079457,701244.439424266 6594353.66268694,701241.476635204 6594350.62715201,701226.456576742 6594352.44472865,701176.30080534 6594365.83460144,701163.304437757 6594365.67698524,701151.222920645 6594372.52953731,701145.345840528 6594362.45958578,701137.723929416 6594331.37125423,701128.787065911 6594326.263533,701108.74415823 6594330.01992955,701093.687729194 6594334.83666787,701085.76271091 6594328.74135065,701097.916972401 6594315.89047541,701102.012848504 6594307.94120838,701103.048941774 6594304.95417109,701101.146494723 6594296.93215851,701088.247122071 6594288.7767794,701076.226227727 6594290.63072959,701037.006769157 6594309.15257288,701021.901844412 6594317.9681929,701004.736857681 6594331.75816609,700991.534379746 6594348.59579707,700986.414534852 6594358.5323794,700981.137073694 6594381.46532643,700970.751890949 6594413.33513462,700958.464261691 6594437.18293049,700932.447284388 6594438.86713699,700915.488412391 6594435.66186148,700880.498202773 6594435.23750801,700856.46854382 6594437.94568351,700853.445134369 6594439.9087508,700856.298802319 6594451.9417667,700835.96491438 6594479.6914444,700832.747513849 6594497.65003468,700840.660404283 6594504.74507173,700867.871090381 6594487.07746788,700884.902707907 6594484.28442262)))'::geometry,0), 'hex');

-- Removing of duplicate points after generalizing
select 'Removing of duplicate points LINESTRING', encode(st_astwkb('LINESTRING(1 1, 2 2, 2 2, 3 1)'::geometry), 'hex');
select 'Removing of duplicate points POLYGON', encode(st_astwkb('POLYGON((1 1,0.6 2.2, 1.2 1.7, 2 2, 2 1, 1 1))'::geometry), 'hex');

-- Not removing from multipoint
select 'Not Removing from MULTIPOINT',encode(st_astwkb('MULTIPOINT(1 1, 2 2, 2 2, 3 1)'::geometry), 'hex');
