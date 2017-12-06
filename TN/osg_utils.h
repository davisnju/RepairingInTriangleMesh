#pragma once
#ifndef _OSG_UTILS_H_
#define _OSG_UTILS_H_

#include <math.h>
#include <windows.h>
#include <fstream>
#include <vector>
#include <osgViewer/Viewer>

using namespace std;
using namespace osg;

Vec3 calcNormal(const Vec3& a, const Vec3& b, const Vec3& c);
bool point3compare(const Vec3& a, const Vec3& b);
vector<Vec3> analyzeNormals(Group *node);

#endif