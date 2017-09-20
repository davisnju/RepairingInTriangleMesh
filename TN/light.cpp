
#include "light.h"


osg::Node* createLightSource(unsigned int num, const osg::Vec3d& trans, const osg::Vec3d &vecDir)
{
    osg::ref_ptr<osg::Light> light = new osg::Light;
    light->setLightNum(num);
    light->setDirection(vecDir);
    //light->setAmbient(osg::Vec4(0.0f,0.0f,0.0f,1.0f));  
    //设置散射光的颜色  
    //light->setDiffuse(osg::Vec4(0.8f,0.8f,0.8f,1.0f));  
    //   
    //light->setSpecular(osg::Vec4(1.0f,1.0f,1.0f,1.0f));  
    //light->setPosition( osg::Vec4(0.0f, 0.0f, 0.0f, 1.0f) );  

    osg::ref_ptr<osg::LightSource> lightSource = new osg::LightSource;
    lightSource->setLight(light);

    osg::ref_ptr<osg::MatrixTransform> sourceTrans = new osg::MatrixTransform;
    sourceTrans->setMatrix(osg::Matrix::translate(trans));
    sourceTrans->addChild(lightSource.get());
    return sourceTrans.release();
}

