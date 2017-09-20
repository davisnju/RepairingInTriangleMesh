#include "stdafx.h"  

#include <osgDB/ReadFile>  
#include <osgViewer/Viewer>  
#include <osg/Node>  
#include <osgFX/Scribe>  
#include <osgGA/GUIEventHandler>  
#include <osgUtil/LineSegmentIntersector>  
#include <osg/MatrixTransform>
#include <osgManipulator/TabBoxDragger>  
#include <osgManipulator/Selection>  
#include <osgManipulator/TrackballDragger>  
#include <osgManipulator/CommandManager> 
#include <osgManipulator/TranslateAxisDragger>
#include <osgManipulator/ScaleAxisDragger>

#include <vector>
using namespace std;
using namespace osg;

class CEventHandler :public osgGA::GUIEventHandler
{
public:


    bool addFireValid;
    bool addModelValid;
    bool addLabelValid;

    bool mModelRotate;
    bool mModelRotating;
    bool mModelTrans;
    bool mModelTransfering;
    bool mModelScale;
    bool mModelScaling;

    int draggerGroupIdx;   // TrackballDragger id
    int tabDraggerGroupIdx; // TabBoxDragger id
	int scaleDraggerGroupIdx; //scaleDragger id

    Group* m_draggerGroup;
    Group* m_tabDraggerGroup;
	Group* m_scaleDraggerGroup;

    CString m_modelname;
    float m_modelsize;
    float m_firescale;

    // Êó±ê×ó¼ü×´Ì¬  
    bool m_bLeftButtonDown;

    // Êó±êÎ»ÖÃ  
    float m_fpushX;
    float m_fpushY;

    CEventHandler()
    {
        m_bLeftButtonDown = false;
        addModelValid = false; 
        addLabelValid = false;
        addFireValid = false;
        mModelRotate = false;
        mModelTrans = false;
        mModelRotating = false;
        mModelTransfering = false;
        mModelScale = false;
        mModelScaling = false;

        m_modelname = "cow";
        m_modelsize = 1.0f;
        m_firescale = 0.0f;
        draggerGroupIdx = -1;
        tabDraggerGroupIdx = -1; 
		scaleDraggerGroupIdx = -1;
        m_draggerGroup = NULL;
        //m_tabDraggerGroup = NULL;
		//m_scaleDraggerGroup = NULL;

        _rectify_H = false;
    };
    virtual bool handle(const osgGA::GUIEventAdapter &ea, osgGA::GUIActionAdapter &aa);

    bool addFire(osgViewer::Viewer* viewer, const osgGA::GUIEventAdapter& ea);
    bool addModel(osgViewer::Viewer* viewer, const osgGA::GUIEventAdapter& ea);
    bool rotateSelected(osgViewer::Viewer* viewer, const osgGA::GUIEventAdapter & ea);
    bool transferSelected(osgViewer::Viewer* viewer, const osgGA::GUIEventAdapter & ea);
    bool removeTrackballDragger(osgViewer::Viewer* viewer);
    bool removeTabDragger(osgViewer::Viewer* viewer);
	bool cancelDragger(osgViewer::Viewer* viewer);
	bool scaleSelected(osgViewer::Viewer* viewer, const osgGA::GUIEventAdapter & ea);
	bool removeScaleDragger(osgViewer::Viewer* viewer);
	bool removeDragger(osgViewer::Viewer* viewer);
    bool addLabel(osgViewer::Viewer* viewer, const osgGA::GUIEventAdapter & ea);
    ref_ptr<Node> creatLabel();


    void RectifyH(bool _rectify_H);
    bool RectifyH(osgViewer::Viewer* viewer, const osgGA::GUIEventAdapter & ea);

private:
    vector<Vec3> _vec_rectify_H;
    bool _rectify_H;
};