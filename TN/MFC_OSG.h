#pragma once

#include <osgViewer/Viewer>
#include <osgViewer/ViewerEventHandlers>
#include <osgViewer/api/win32/GraphicsWindowWin32>
#include <osgGA/TrackballManipulator>
#include <osgGA/DriveManipulator>
#include <osgGA/KeySwitchMatrixManipulator>
#include <osgGA/TerrainManipulator>
#include <osgDB/DatabasePager>
#include <osgDB/Registry>
#include <osgDB/ReadFile>
#include <osgUtil/Optimizer>

#include <osgWidget/WindowManager>

// x64
// #include <osgViewer/GraphicsWindow>

#include <string>

#include "EventHandler.h"
#include "NaviManipulator.h"

using namespace osg;
using namespace osgGA;

class cOSG
{
public:
    CNaviManipulator* m_naviManipulator;
    TerrainManipulator* m_terrainManipulator;

    cOSG(HWND hWnd);
    ~cOSG();

    void InitOSG(CString initModelName);
    void InitOSG();

    void InitManipulators(void);
    void InitSceneGraph(void);
    void InitCameraConfig(void);
    void SetupWindow(void);
    void SetupCamera(void);
    void PreFrameUpdate(void);
    void PostFrameUpdate(void);
    void Done(bool value) { mDone = value; }
    bool Done(void) { return mDone; }
    static void Render(void* ptr);
    bool osgThreadDone;
    // osgWidget
    ref_ptr<osgWidget::Box> _InfoLabelBox;
    void _createLabelBox();

    osgViewer::Viewer* getViewer() { return mViewer; }

    ref_ptr<Group> getRoot() { return mRoot; }

    void setNaviMode(int n)
    {
        m_naviManipulator->naviMode = n;
    }

    void setEditMode(int e)
    {
        if (e < 0)
        {
            if (m_eventHandler->mModelRotating
                || m_eventHandler->mModelTransfering
                || m_eventHandler->mModelScaling)
            {
                m_eventHandler->removeDragger(mViewer);
            }
            return;
        }
        m_eventHandler->addModelValid = e == EDIT_MODE_ADD_MODEL;
        m_eventHandler->addLabelValid = e == EDIT_MODE_ADD_LABEL;
        m_eventHandler->addFireValid = e == EDIT_MODE_ADD_FIRE;
        if (m_eventHandler->mModelRotating
            || m_eventHandler->mModelTransfering
            || m_eventHandler->mModelScaling)
            m_eventHandler->removeDragger(mViewer);
        m_eventHandler->mModelRotate = e == EDIT_MODE_ROTATE;
        m_eventHandler->mModelTrans = e == EDIT_MODE_TRANS;
        m_eventHandler->mModelScale = e == EDIT_MODE_SCALE;
    }

    void setSelectModel()
    {};

    void addNewModels();
    void addNewModels(bool a);
    void dontAddNewModels();
    void addEffects();
    void addEffects(bool f);
    void dontAddEffects();

    void rotateModel(bool r)
    {
        m_eventHandler->mModelRotate = r;
    };
    void transferModel(bool t)
    {
        m_eventHandler->mModelTrans = t;
    };
    void scaleModel(bool s)
    {
        m_eventHandler->mModelScale = s;
    };

    void setNewModel(CString modelname, CString nodename = TEXT(""));
    void setModelSize(float s)
    {
        if (abs(s) > 1000000.0)
        {
            AfxMessageBox(_T("model size too large"));
            return;
        }
        m_eventHandler->m_modelsize = s;
    };

    void setFireSize(float s)
    {
        if (abs(s) > 1000000.0)
        {
            AfxMessageBox(_T("fire size too large"));
            return;
        }
        m_eventHandler->m_firescale = s;
    };

    ref_ptr<Node> createBase(const Vec3& center, float radius);
    ref_ptr<Geode> createAxis();

    osgWidget::Box* createSimpleTabs(float winX, float winY);
    void stopThread();
    void rerunThread();
    void setRoot(ref_ptr<Group> newSceneNode);
    void fixInitCamera();

    void editLabelName(CString tarLabel, CString name);
    void deleteLabel(CString tarLabel);
    Node * getNodeByName(ref_ptr<Group> mRoot, std::string nodeName);
    void moveCameratoNode(std::string nodeName);
    void moveCameratoNode(Node* tarNode);
    void moveCameratoLabel(CString cstrLabel);

    void getJustCurrentDir(CString path, std::list<CString>& files);
    int getNumInRect(ref_ptr<Vec3Array> triPoints
                     , ref_ptr<Vec3Array> rect
                     , std::vector<int>& triIndex);
    bool isInRect(ref_ptr<Vec3Array> oneTriPoints, ref_ptr<Vec3Array> rect);
    Node* creatMesh(ref_ptr<Vec3Array> triPointsInRect,
                    ref_ptr<Vec2Array> triTexInRect);
    void RectifyH();
    bool isRectifingH() { return _rectify_H; };
    void addLights();
    void addTr();
    osg::ref_ptr<osg::Geode> createTr(osg::ref_ptr<osg::Vec3Array> vertex,
                                      osg::ref_ptr<osg::Vec4Array> vertex_color,
                                      osg::ref_ptr<osg::Vec3Array> normal);
    void addPatch(CString & patch_file);
    void addBorder();
private:

    CEventHandler* m_eventHandler;

    bool _rectify_H;

    bool mDone;
    std::string m_ModelName;
    HWND m_hWnd;
    osgViewer::Viewer* mViewer;
    ref_ptr<Group> mRoot;
    ref_ptr<Node> mModel;
};

class CRenderingThread : public OpenThreads::Thread
{
public:
    CRenderingThread(cOSG* ptr);
    virtual ~CRenderingThread();

    virtual void run();

protected:
    cOSG* _ptr;
    bool _done;
};
