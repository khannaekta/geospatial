---
--- SFCGAL backend tests based on GEOS/JTS implemented functions
---
---

SET postgis.backend = 'sfcgal';

\cd :regdir
\i concave_hull.sql