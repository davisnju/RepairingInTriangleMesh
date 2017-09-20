#pragma once
#include <Windows.h>
#include <osg/MatrixTransform>
#include <osg/Light>
#include <osg/LightSource>
#include <osgViewer/Viewer>

osg::Node* createLightSource(unsigned int num, const osg::Vec3d& trans,
                             const osg::Vec3d &vecDir);

