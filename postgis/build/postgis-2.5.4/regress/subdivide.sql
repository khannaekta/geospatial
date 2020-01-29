-- polygon
WITH g AS (SELECT 'POLYGON((132 10,119 23,85 35,68 29,66 28,49 42,32 56,22 64,32 110,40 119,36 150,
57 158,75 171,92 182,114 184,132 186,146 178,176 184,179 162,184 141,190 122,
190 100,185 79,186 56,186 52,178 34,168 18,147 13,132 10))'::geometry As geom)
, gs AS (SELECT ST_Area(geom) As full_area, ST_Subdivide(geom,10) As geom FROM g)
SELECT '1' As rn, full_area::numeric(10,3) = SUM(ST_Area(gs.geom))::numeric(10,3), COUNT(gs.geom) As num_pieces, MAX(ST_NPoints(gs.geom)) As max_vert
FROM gs
GROUP BY gs.full_area;

-- linestring
WITH g AS (SELECT ST_Segmentize('LINESTRING(0 0, 10 10, 15 15)'::geography,150000)::geometry As geom)
, gs AS (SELECT ST_Length(geom) As m, ST_Subdivide(geom,8) As geom FROM g)
SELECT '2' As rn, m::numeric(10,3) = SUM(ST_Length(gs.geom))::numeric(10,3), COUNT(gs.geom) As num_pieces, MAX(ST_NPoints(gs.geom)) As max_vert
FROM gs
GROUP BY gs.m;

-- multipolygon
WITH g AS (SELECT 'POLYGON((132 10,119 23,85 35,68 29,66 28,49 42,32 56,22 64,32 110,40 119,36 150,
57 158,75 171,92 182,114 184,132 186,146 178,176 184,179 162,184 141,190 122,
190 100,185 79,186 56,186 52,178 34,168 18,147 13,132 10))'::geometry As geom)
, gs AS (SELECT ST_Area(ST_Union(g.geom, ST_Translate(g.geom,300,10) )) As full_area, ST_Subdivide(ST_Union(g.geom, ST_Translate(g.geom,300,10) ), 10) As geom FROM g)
SELECT '3' As rn, full_area::numeric(10,3) = SUM(ST_Area(gs.geom))::numeric(10,3), COUNT(gs.geom) As num_pieces, MAX(ST_NPoints(gs.geom)) As max_vert
FROM gs
GROUP BY gs.full_area;

SELECT '#3135', st_astext(ST_Subdivide(ST_GeomFromText('POLYGON((1 2,1 2,1 2,1 2))'), 2));
SELECT '#3522', ST_AsText(ST_Subdivide(ST_GeomFromText('POINT(1 1)',4326),10));

with inverted_geom as (
    select ST_Difference(
               ST_Expand('SRID=3857;POINT(0 0)' :: geometry, 20000000),
               ST_Buffer(
                   'SRID=3857;POINT(0 0)' :: geometry,
                   1,
                   1000
               )
           ) as geom
)
select '#3744', ST_Area(ST_Simplify(ST_Union(geom), 2))::numeric
from (
         select ST_Subdivide(geom) geom
         from inverted_geom
     ) z;

\i regress_big_polygon.sql

set client_min_messages = 'warning';
create table big_polygon_sliced as (
	select ST_Subdivide(geom) As geom FROM big_polygon
);
reset client_min_messages;
-- regression big polygon
SELECT '4' As rn,
	(select ST_Area(geom)::numeric(12,1) from big_polygon) as orig_area,
	SUM(ST_Area(gs.geom))::numeric(12,1) as pieces_area,
	COUNT(gs.geom) as num_pieces,
	MAX(ST_NPoints(gs.geom)) as max_vert
FROM big_polygon_sliced gs;

drop table big_polygon;
drop table big_polygon_sliced;

select '#4211', (select sum(ST_Area(geom))::numeric(12,11) from ST_Subdivide('MULTIPOLYGON(((-88.2059 41.7325,-88.2060 41.7244,-88.1959 41.7241,-88.1959 41.7326,-88.2059 41.7325),(-88.1997 41.7289,-88.1996 41.7285,-88.1990 41.7285,-88.1990 41.7289,-88.1997 41.7289)))') geom );

select '#4217', (select sum(ST_Area(geom))::numeric(12,11) from ST_Subdivide('0103000000140000006500000002773098F45057C024E3F62915844640CDE0FEEEF95057C024E3F62915844640CDE0FEEEF95057C0B9B693D71F844640974ACD45FF5057C0B9B693D71F844640974ACD45FF5057C024E3F6291584464062B49B9C045157C024E3F62915844640F787384A0F5157C024E3F62915844640F787384A0F5157C08F0F5A7C0A844640C1F106A1145157C08F0F5A7C0A844640C1F106A1145157C024E3F629158446408C5BD5F7195157C024E3F629158446408C5BD5F7195157C08F0F5A7C0A84464056C5A34E1F5157C08F0F5A7C0A84464056C5A34E1F5157C078316AE03F8446408C5BD5F7195157C078316AE03F8446408C5BD5F7195157C00D05078E4A84464056C5A34E1F5157C00D05078E4A84464056C5A34E1F5157C0A2D8A33B55844640212F72A5245157C0A2D8A33B55844640212F72A5245157C038AC40E95F84464056C5A34E1F5157C038AC40E95F8446408C5BD5F7195157C038AC40E95F8446408C5BD5F7195157C0CD7FDD966A84464056C5A34E1F5157C0CD7FDD966A84464056C5A34E1F5157C062537A44758446408C5BD5F7195157C062537A44758446408C5BD5F7195157C08CFAB39F8A8446402C1E6AF3095157C08CFAB39F8A8446402C1E6AF3095157C0F72617F27F844640CDE0FEEEF95057C0F72617F27F844640CDE0FEEEF95057C08CFAB39F8A844640D8CFF63CDF5057C08CFAB39F8A844640D8CFF63CDF5057C0F72617F27F8446400E6628E6D95057C0F72617F27F8446400E6628E6D95057C08CFAB39F8A84464090707BD4995057C08CFAB39F8A84464090707BD4995057C0CD7FDD966A844640C506AD7D945057C0CD7FDD966A844640C506AD7D945057C062537A4475844640FA9CDE268F5057C062537A4475844640FA9CDE268F5057C08CFAB39F8A844640303310D0895057C08CFAB39F8A844640303310D0895057C0F72617F27F84464065C94179845057C0F72617F27F84464065C94179845057C08CFAB39F8A8446403B22081E6F5057C08CFAB39F8A8446403B22081E6F5057C0F72617F27F844640A64E6B70645057C0F72617F27F844640A64E6B70645057C08CFAB39F8A8446404711006C545057C08CFAB39F8A8446404711006C545057C062537A44758446407CA731154F5057C062537A44758446407CA731154F5057C0CD7FDD966A8446404711006C545057C0CD7FDD966A844640A64E6B70645057C0CD7FDD966A844640A64E6B70645057C038AC40E95F844640DCE49C195F5057C038AC40E95F844640DCE49C195F5057C0A2D8A33B55844640A64E6B70645057C0A2D8A33B55844640A64E6B70645057C078316AE03F8446403B22081E6F5057C078316AE03F8446403B22081E6F5057C00D05078E4A84464065C94179845057C00D05078E4A84464065C94179845057C078316AE03F844640FA9CDE268F5057C078316AE03F844640FA9CDE268F5057C00D05078E4A844640C506AD7D945057C00D05078E4A844640C506AD7D945057C0A2D8A33B5584464090707BD4995057C0A2D8A33B5584464090707BD4995057C038AC40E95F84464025441882A45057C038AC40E95F84464025441882A45057C0CD7FDD966A8446405ADA492B9F5057C0CD7FDD966A8446405ADA492B9F5057C0F72617F27F84464079928B38CF5057C0F72617F27F84464079928B38CF5057C0B9B693D71F844640AE28BDE1C95057C0B9B693D71F844640AE28BDE1C95057C024E3F6291584464079928B38CF5057C024E3F6291584464079928B38CF5057C08F0F5A7C0A84464043FC598FD45057C08F0F5A7C0A84464043FC598FD45057C0D0948373EA8346400E6628E6D95057C0D0948373EA834640D8CFF63CDF5057C0D0948373EA834640D8CFF63CDF5057C0A6ED4918D5834640A339C593E45057C0A6ED4918D58346406DA393EAE95057C0A6ED4918D58346406DA393EAE95057C03BC1E6C5DF834640A339C593E45057C03BC1E6C5DF834640A339C593E45057C0D0948373EA83464002773098F45057C0D0948373EA83464002773098F45057C03BC1E6C5DF834640CDE0FEEEF95057C03BC1E6C5DF834640CDE0FEEEF95057C0D0948373EA83464062B49B9C045157C0D0948373EA83464062B49B9C045157C065682021F58346402C1E6AF3095157C065682021F58346402C1E6AF3095157C0FA3BBDCEFF834640CDE0FEEEF95057C0FA3BBDCEFF83464002773098F45057C0FA3BBDCEFF83464002773098F45057C024E3F629158446400500000065C94179845057C00D05078E4A84464065C94179845057C0A2D8A33B55844640303310D0895057C0A2D8A33B55844640303310D0895057C00D05078E4A84464065C94179845057C00D05078E4A8446400500000002773098F45057C0A2D8A33B55844640CDE0FEEEF95057C0A2D8A33B55844640CDE0FEEEF95057C00D05078E4A84464002773098F45057C00D05078E4A84464002773098F45057C0A2D8A33B558446400500000002773098F45057C0A2D8A33B55844640380D6241EF5057C0A2D8A33B55844640380D6241EF5057C038AC40E95F84464002773098F45057C038AC40E95F84464002773098F45057C0A2D8A33B5584464007000000A339C593E45057C0A2D8A33B55844640A339C593E45057C00D05078E4A8446400E6628E6D95057C00D05078E4A8446400E6628E6D95057C078316AE03F84464043FC598FD45057C078316AE03F84464043FC598FD45057C0A2D8A33B55844640A339C593E45057C0A2D8A33B558446400D00000062B49B9C045157C078316AE03F84464062B49B9C045157C0A2D8A33B558446402C1E6AF3095157C0A2D8A33B558446402C1E6AF3095157C038AC40E95F84464062B49B9C045157C038AC40E95F84464062B49B9C045157C0CD7FDD966A8446402C1E6AF3095157C0CD7FDD966A844640C1F106A1145157C0CD7FDD966A844640C1F106A1145157C0E35DCD3235844640F787384A0F5157C0E35DCD3235844640F787384A0F5157C078316AE03F8446402C1E6AF3095157C078316AE03F84464062B49B9C045157C078316AE03F8446400500000062B49B9C045157C0CD7FDD966A844640974ACD45FF5057C0CD7FDD966A844640974ACD45FF5057C062537A447584464062B49B9C045157C062537A447584464062B49B9C045157C0CD7FDD966A84464005000000D8CFF63CDF5057C04E8A30852A84464043FC598FD45057C04E8A30852A84464043FC598FD45057C0E35DCD3235844640D8CFF63CDF5057C0E35DCD3235844640D8CFF63CDF5057C04E8A30852A84464006000000F787384A0F5157C04E8A30852A844640F787384A0F5157C0B9B693D71F84464062B49B9C045157C0B9B693D71F84464062B49B9C045157C04E8A30852A8446402C1E6AF3095157C04E8A30852A844640F787384A0F5157C04E8A30852A8446400500000062B49B9C045157C04E8A30852A844640974ACD45FF5057C04E8A30852A844640974ACD45FF5057C078316AE03F84464062B49B9C045157C078316AE03F84464062B49B9C045157C04E8A30852A844640050000003B22081E6F5057C00D05078E4A84464071B839C7695057C00D05078E4A84464071B839C7695057C0A2D8A33B558446403B22081E6F5057C0A2D8A33B558446403B22081E6F5057C00D05078E4A844640050000006DA393EAE95057C04E8A30852A8446406DA393EAE95057C0E35DCD323584464002773098F45057C0E35DCD323584464002773098F45057C04E8A30852A8446406DA393EAE95057C04E8A30852A84464005000000D8CFF63CDF5057C04E8A30852A8446406DA393EAE95057C04E8A30852A8446406DA393EAE95057C0B9B693D71F844640D8CFF63CDF5057C0B9B693D71F844640D8CFF63CDF5057C04E8A30852A844640050000006DA393EAE95057C08F0F5A7C0A8446406DA393EAE95057C0FA3BBDCEFF834640A339C593E45057C0FA3BBDCEFF834640A339C593E45057C08F0F5A7C0A8446406DA393EAE95057C08F0F5A7C0A8446400500000002773098F45057C024E3F62915844640380D6241EF5057C024E3F62915844640380D6241EF5057C0B9B693D71F84464002773098F45057C0B9B693D71F84464002773098F45057C024E3F62915844640060000003B22081E6F5057C062537A44758446403B22081E6F5057C0CD7FDD966A84464071B839C7695057C0CD7FDD966A844640A64E6B70645057C0CD7FDD966A844640A64E6B70645057C062537A44758446403B22081E6F5057C062537A4475844640050000003B22081E6F5057C0CD7FDD966A844640068CD674745057C0CD7FDD966A844640068CD674745057C038AC40E95F8446403B22081E6F5057C038AC40E95F8446403B22081E6F5057C0CD7FDD966A84464009000000068CD674745057C0CD7FDD966A844640068CD674745057C0F72617F27F844640D0F5A4CB795057C0F72617F27F844640D0F5A4CB795057C062537A44758446409B5F73227F5057C062537A4475844640303310D0895057C062537A4475844640303310D0895057C0CD7FDD966A844640D0F5A4CB795057C0CD7FDD966A844640068CD674745057C0CD7FDD966A84464005000000D8CFF63CDF5057C062537A4475844640D8CFF63CDF5057C0CD7FDD966A8446400E6628E6D95057C0CD7FDD966A8446400E6628E6D95057C062537A4475844640D8CFF63CDF5057C062537A447584464005000000380D6241EF5057C062537A4475844640380D6241EF5057C0CD7FDD966A844640A339C593E45057C0CD7FDD966A844640A339C593E45057C062537A4475844640380D6241EF5057C062537A4475844640', 10) geom);

select '#4301', (select sum(ST_Area(geom))::numeric(12,11) from ST_Subdivide('0103000020E61000002800000069000000A84F0FE6B3EE4FC0A58B86253F5E4C40CDE58612CBEE4FC0076A685F255E4C40206D718DCFEE4FC0F8997ADD225E4C40686A6798DAEE4FC0C1CC5B751D5E4C4068FE5F75E4EE4FC0B0436E861B5E4C40F8C874E8F4EE4FC0805BB054175E4C40C0FA3F87F9EE4FC03078431A155E4C40C07FBA8102EF4FC0F12494BE105E4C403810CB660EEF4FC059EE77280A5E4C40A974779D0DEF4FC0D88D3EE6035E4C4040CADDE7F8EE4FC0A85AD2510E5E4C4040060E68E9EE4FC081C34483145E4C40096D3997E2EE4FC018CA8976155E4C4090906CECD9EE4FC06BFFF9DA145E4C400A8044E11EEF4FC0BBD33D2AC85D4C40BA92DC3AB1EF4FC02BAA488D5A5D4C4074DAA2EB57F04FC022A5B46D095D4C40E4A00B8B0CF14FC0021BFDE9D75C4C40D8353027C8F14FC01AE17FE9C75C4C4057C5468983F24FC09CFCB809DA5C4C402DA8C57C37F34FC0980233980D5D4C406FCB6F16DDF34FC0D5226899605D4C40E0CA88F86DF44FC06E5D4FDCCF5D4C40ACB36AC4CEF44FC0E2194C3D3E5E4C40E003745FCEF44FC01860915F3F5E4C4080FFAD64C7F44FC040C95697535E4C4076A47AC5CEF44FC0DF35823E3E5E4C4042728C91E4F44FC042A9D319575E4C402440FD523CF54FC032D9FC1EF15E4C40E9C62DDE71F54FC0EE7D2800985F4C40BAF04D2583F54FC02AF6575345604C4056EF7A7F6FF54FC0E8BD536FF2604C40832012AF37F54FC0A66935AD98614C400C2F0FDADDF44FC05E39D3A931624C40A3DDC67465F44FC012838A84B7624C4049F7D41FD3F34FC01819011925634C4084E78F7A2CF34FC08815A83176634C40C6E0C62AECF24FC05ADAC7D287634C4068C9FFE4EFF24FC0C0CE86FC33634C40D5B01AB1F0F24FC0F7EB20351A634C40E9FFF324ECF24FC0CE8C60D487634C40B402C3EB77F24FC0AA0F12B1A7634C4086A9CD62BCF14FC02DE688B0B7634C40FFFE8D1301F14FC01E86B892A5634C40456CAF2F4DF04FC01876B80972634C4051010EA0A7EF4FC0B21639101F634C40F511DFC016EF4FC05CEB16D6AF624C40BC3D3523A0EE4FC0F73211A128624C40B437435648EE4FC0700BD5A28E614C4090CF76BA12EE4FC082F6F6C5E7604C4083CF7DA802EE4FC0C3742A4347604C40B042588D25EE4FC0F0A221E351604C4070ED444948EE4FC0C872124A5F604C40A8169F0260EE4FC0884BC79C67604C40D8A9B9DC60EE4FC0AEC1FBAA5C604C405863096B63EE4FC07006B8205B604C4078F6234564EE4FC058CF108E59604C405863096B63EE4FC0C873284355604C40A8169F0260EE4FC0A005DA1D52604C4098AF20CD58EE4FC058293DD34B604C40C8DE196D55EE4FC0C7CD548847604C4030950C0055EE4FC088285FD042604C4030950C0055EE4FC0E9CC76853E604C40E86ED74B53EE4FC028F73B1405604C402001DC2C5EEE4FC088681F2BF85F4C40887EFB3A70EE4FC0F86C1D1CEC5F4C4090CBB8A981EE4FC0B01611C5E45F4C40D948A0C1A6EE4FC092CD8E54DF5F4C4050A1F31ABBEE4FC0706EBE11DD5F4C4080889B53C9EE4FC0E9C3EC65DB5F4C4078D9CBB6D3EE4FC0A07FBBECD75F4C404029931ADAEE4FC0B831E884D05F4C405876887FD8EE4FC0A0FEB3E6C75F4C404821E527D5EE4FC0D9FDD5E3BE5F4C40A001F566D4EE4FC0F8C9C342AD5F4C40783A90F5D4EE4FC028446B459B5F4C4088CA4DD4D2EE4FC0F0255470785F4C40F18FBE49D3EE4FC09785AFAF755F4C40F0921B45D6EE4FC098FCC1C0735F4C4090F7AA9509EF4FC0B2B5BE48685F4C40404DF4F928EF4FC0E809849D625F4C40908C9C853DEF4FC03E471D1D575F4C403058FFE730EF4FC0A0573CF5485F4C40B890477023EF4FC0C0874B8E3B5F4C4038C98FF815EF4FC0A0FC169D2C5F4C40301F49490FEF4FC0287B849A215F4C4000D369DD06EF4FC0B2F9F197165F4C4000B68311FBEE4FC000CFF6E80D5F4C4008357C0BEBEE4FC087289831055F4C4020ABB019E0EE4FC0800BB265F95E4C40F17CCD72D9EE4FC04137FB03E55E4C40E836A8FDD6EE4FC0075FD1ADD75E4C4088CA4DD4D2EE4FC0F0F4F57CCD5E4C40E0284014CCEE4FC0C0654E97C55E4C4060C5A9D6C2EE4FC048E4BB94BA5E4C40591B6327BCEE4FC088703E75AC5E4C4041395FECBDEE4FC01F4B1FBAA05E4C40808C0E48C2EE4FC061FC6D4F905E4C4080AA0A0DC4EE4FC060045438825E4C4070C806D2C5EE4FC0987A8846775E4C40D03B31EBC5EE4FC018E71A66685E4C4050D89AADBCEE4FC079F7393E5A5E4C40204696CCB1EE4FC0C0990AF1485E4C40A042AED4B3EE4FC0A8EC66463F5E4C40A84F0FE6B3EE4FC0A58B86253F5E4C4004000000A0608DB3E9F04FC0D1129D6516634C40A826C11BD2F04FC070C328081E634C40A826C11BD2F04FC0403F8C101E634C40A0608DB3E9F04FC0D1129D6516634C4005000000A826C11BD2F04FC0403F8C101E634C4078E04BC4D0F04FC08044C3D01D634C403CE04BC4D0F04FC07744C3D01D634C4070E04BC4D0F04FC08044C3D01D634C40A826C11BD2F04FC0403F8C101E634C4004000000B8FD2B2B4DF44FC01889D00836604C40703A02B859F44FC04032569BFF5F4C40E884251E50F44FC0A06FD23428604C40B8FD2B2B4DF44FC01889D00836604C4004000000703A02B859F44FC04032569BFF5F4C40808384285FF44FC0C19FFEB3E65F4C4000840F255AF44FC0A0B1A19BFD5F4C40703A02B859F44FC04032569BFF5F4C4021000000723435F881F04FC048363FFF3D604C4002CAD8BE87F04FC0AA7C6AC577604C40D63D9A9B99F04FC0C0E5D964AF604C40C836A4DEB6F04FC014C25DBAE2604C4051BD0368DEF04FC019E4FBCC0F614C40AFE2BBB20EF14FC04ADA55E134614C4083BBB9E345F14FC08AADB08A50614C404A6615DC81F14FC07BEAF6B861614C4011A5EC4DC0F14FC05E7A2BC367614C40ED410AD3FEF14FC047CAE66D62614C40E1F57B043BF24FC0969E9EED51614C40FF7D2F9272F24FC02C3AA2E436614C406B47AF59A3F24FC060A2DE5C12614C40E1A11F7BCBF24FC08029A8BDE5604C40036AAE6BE9F24FC07276EDBDB2604C40A1F8BF04FCF24FC07F7D5B537B604C40B6EF438F02F34FC0DCF2179F41604C406D0BC2CAFCF24FC0FE84CFD807604C40FC05D9EFEAF24FC096B6E538D05F4C40284C16AECDF24FC04FD99CE29C5F4C4078033B25A6F24FC0AC180DCF6F5F4C40BCF82FDA75F24FC002AFB9B94A5F4C4014B614A83EF24FC0728D830F2F5F4C40A190FCAD02F24FC0848AA1E01D5F4C4054710D3AC4F14FC0067428D6175F4C402F23CEB285F14FC0994B8A2B1D5F4C40D700847F49F14FC09EDC4CAC2D5F4C409C3989F011F14FC0FC410EB6485F4C4059328528E1F04FC06678C33E6D5F4C4043BD6707B9F04FC0C064F3DE995F4C40F55EF6179BF04FC01C6689DFCC5F4C40014BA18088F04FC00C25B74A04604C40723435F881F04FC048363FFF3D604C40040000007C2A357BA0F34FC0B739799109624C40802A357BA0F34FC0B039799109624C40F88079C894F34FC098CE876709624C407C2A357BA0F34FC0B739799109624C400400000019247D5A45F34FC0F0E2E13D07624C405879909E22F34FC0B0D5575705624C405879909E22F34FC0B1D5575705624C4019247D5A45F34FC0F0E2E13D07624C4004000000D9D9571EA4EF4FC0886308008E5D4C40D833846396EF4FC0485AF10D855D4C4010CE6E2D93EF4FC010E275FD825D4C40D9D9571EA4EF4FC0886308008E5D4C400500000010D9CEF753F34FC0A87422C1545D4C4000B5183C4CF34FC0108F368E585D4C40E054320054F34FC082F085C9545D4C40D05CE0F258F34FC03826C45C525D4C4010D9CEF753F34FC0A87422C1545D4C40050000004875C8CD70F34FC020F032C3465D4C4080D7F50B76F34FC0A936E334445D4C40B8E00CFE7EF34FC060E333D93F5D4C40B05B920376F34FC0A836E334445D4C404875C8CD70F34FC020F032C3465D4C40040000006967D13B15F24FC028E78BBD175D4C40E02D90A0F8F14FC008184163265D4C40886A662D05F24FC0704C16F71F5D4C406967D13B15F24FC028E78BBD175D4C400400000020F224E99AF14FC0511AA375545D4C40504277499CF14FC08F54DFF9455D4C40C82F116F9DF14FC00113B875375D4C4020F224E99AF14FC0511AA375545D4C40040000001057957D57F24FC09AB27E33315D4C4070A296E656F24FC0D85E44DB315D4C4038F92D3A59F24FC0009DBB5D2F5D4C401057957D57F24FC09AB27E33315D4C400400000028862D3D9AF04FC042C5438A015E4C4078A911FA99F04FC01A035DFB025E4C4030B0A5EC99F04FC098733C4D035E4C4028862D3D9AF04FC042C5438A015E4C400400000050B6813B50F34FC0A05E9B8D955E4C40F04927124CF34FC0A89F3715A95E4C4010DD41EC4CF34FC0286C787AA55E4C4050B6813B50F34FC0A05E9B8D955E4C400500000020DEC83CF2F34FC0909048DBF85D4C401885B2F0F5F34FC0F8AFE595EB5D4C40B0A371A8DFF34FC05A8847E2E55D4C40A01188D7F5F34FC0F8AFE595EB5D4C4020DEC83CF2F34FC0909048DBF85D4C4004000000A897A60870F44FC010570740DC5D4C400012DD806DF44FC02013CF8BD75D4C40005ABA826DF44FC0B02D7590D75D4C40A897A60870F44FC010570740DC5D4C400400000069813D2652F44FC00A31D0B52F5E4C40D07AF83251F44FC0E801D715335E4C40A09CC2A74EF44FC0F7103C523C5E4C4069813D2652F44FC00A31D0B52F5E4C4005000000188A3BDEE4F34FC00801F9122A5E4C40207E1AF7E6F34FC09AD40968225E4C400CD9E5C2E9F34FC006DB5D13185E4C4058DDEA39E9F34FC040048E041A5E4C40188A3BDEE4F34FC00801F9122A5E4C40040000006893DFA293F34FC078CF81E5085F4C40B824CE8AA8F34FC0909E94490D5F4C405012A0A696F34FC00000E484095F4C406893DFA293F34FC078CF81E5085F4C4004000000C0F306D363F24FC0412FD6A9A45E4C40F8AF73D366F24FC040852348A55E4C40C0E49B6D6EF24FC040D769A4A55E4C40C0F306D363F24FC0412FD6A9A45E4C400400000049CE177B2FF24FC0D8D9907F665E4C408030B77BB9F14FC0F85AD07B635E4C4011786000E1F14FC03059DC7F645E4C4049CE177B2FF24FC0D8D9907F665E4C4004000000282158552FF34FC0209DF3531C5F4C4008685BCD3AF34FC008952A51F65E4C40300E677E35F34FC048D175E1075F4C40282158552FF34FC0209DF3531C5F4C4004000000600A0F9A5DF54FC0F057C85C19604C404062F4DC42F54FC0903A3AAE46604C40308672A25DF54FC01FDC645419604C40600A0F9A5DF54FC0F057C85C19604C4005000000C0552C7E53F04FC090BD175FB4614C408823D6E253F04FC0682E7079AC614C40C834D3BD4EF04FC02823A0C211624C40F0D9C87553F04FC0387216F6B4614C40C0552C7E53F04FC090BD175FB4614C4005000000E0DBF4673FF04FC0C8D617096D614C40A08EC70C54F04FC0797077D66E614C40B082A62556F04FC090DB68006F614C4048EA92718CF04FC0F804FBAF73614C40E0DBF4673FF04FC0C8D617096D614C400400000020DA5548F9F34FC0B0ED5F5969604C40580CACE3F8F34FC0A064726A67604C4090075BECF6F34FC0B7D3D68860604C4020DA5548F9F34FC0B0ED5F5969604C400400000028AF230ED9F04FC0C88844A165614C40C05C52B5DDF04FC02175ADBD4F614C40B0D7D7BAD4F04FC0807EDFBF79614C4028AF230ED9F04FC0C88844A165614C4004000000E803C93B87F44FC0C0EB17EC86614C401888653387F44FC080677BF486614C40D08A6F287CF44FC0E836E15E99614C40E803C93B87F44FC0C0EB17EC86614C4004000000101AFA27B8F04FC0D03368E89F624C409056B5A4A3F04FC06029CB10C7624C4020766D6FB7F04FC0D1FF1D51A1624C40101AFA27B8F04FC0D03368E89F624C4005000000B856D0B4C4F04FC0A86C91B41B634C40A8EAC891CEF04FC0D80E2A711D634C4079F0C891CEF04FC0D00F2A711D634C40B8EAC891CEF04FC0D00E2A711D634C40B856D0B4C4F04FC0A86C91B41B634C4004000000F8E59315C3F14FC0709291B3B0634C40286EA301BCF14FC068E84A04AA634C40ACF5B4EBA8F14FC0D4B4101C98634C40F8E59315C3F14FC0709291B3B0634C400400000088DE701FB9F14FC000DE02098A634C40E78F15E7A8F14FC07066B81798634C40E88F15E7A8F14FC07166B81798634C4088DE701FB9F14FC000DE02098A634C400400000018618A7269F24FC01863997E89624C4078772B4B74F24FC000B804E09F624C405880EF366FF24FC081F3A96395624C4018618A7269F24FC01863997E89624C4005000000185E920376F14FC0D4470A2C80634C40F86706F181F14FC0F0D0B01875634C4000E15F048DF14FC060F3AACE6A634C40806DFDF49FF14FC088BF982D59634C40185E920376F14FC0D4470A2C80634C400600000000A0C37C79F14FC0E01115AA9B634C4090DB68006FF14FC0B021718FA5634C40C82F116F9DF14FC058FA42C879634C40906665FB90F14FC0B01F628385634C4000AE2B6684F14FC059340F6091634C4000A0C37C79F14FC0E01115AA9B634C4005000000B8287AE063F24FC0C079AA436E624C40905033A48AF24FC0201A4F0471624C40E0ED7A698AF24FC020AD31E884624C4060CC96AC8AF24FC0201A4F0471624C40B8287AE063F24FC0C079AA436E624C400400000030C1FEEBDCF24FC0F9BA0CFFE9624C4030C1FEEBDCF24FC0293FA9F6E9624C401071AC8BDBF24FC02841B8020A634C4030C1FEEBDCF24FC0F9BA0CFFE9624C4004000000E8F065A208F34FC01887FA5DD8624C406005F86EF3F24FC008B1170AD8624C40C83FC969F3F24FC09F7D3287D8624C40E8F065A208F34FC01887FA5DD8624C40'::geometry, 10) geom);
