/**********************************************************************
 *
 * PostGIS - Spatial Types for PostgreSQL
 * http://postgis.net
 * Copyright 2010 LISAsoft Pty Ltd
 * Modifications Copyright (c) 2017 - Present Pivotal Software, Inc. All Rights Reserved.
 *
 * This is free software; you can redistribute and/or modify it under
 * the terms of the GNU General Public Licence. See the COPYING file.
 *
 **********************************************************************/

#ifndef __cu_shp2pgsql_h__
#define __cu_shp2pgsql_h__

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "CUnit/Basic.h"

/***********************************************************************
** for Computational Geometry Suite
*/

/* Admin functions */
int init_shp2pgsql_suite(void);
int clean_shp2pgsql_suite(void);

#endif /* __cu_shp2pgsql_h__ */
