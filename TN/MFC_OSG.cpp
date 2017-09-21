// MFC_OSG.cpp : implementation of the cOSG class
//
#include "stdafx.h"
#include "MFC_OSG.h"
#include "findNodeVisitor.h"
#include <windows.h>

#include <osg/Geometry>
#include <osg/Shape>
#include <osg/ShapeDrawable>
#include <osg/MatrixTransform>
#include <osg/PositionAttitudeTransform>
#include <osg/Texture2D>
#include <osg/TexGen>
#include <osg/TexEnv>
#include <osgDB/ReadFile>
#include <osgViewer/Viewer>
#include <osgViewer/ViewerEventHandlers>

#include <osgGA/GUIEventAdapter>  
#include <osgGA/StateSetManipulator>
#include <osgManipulator/TabBoxDragger>  
#include <osgManipulator/Selection>  
#include <osgManipulator/TrackballDragger>  
#include <osgManipulator/CommandManager> 
#include <osg/Camera>

#include "TNApp.h"
#include "MainFrm.h"
#include "TNDoc.h"

#include "MeshNodeVisitor.h"

#include "light.h"

cOSG::cOSG(HWND hWnd) :
m_hWnd(hWnd)
, osgThreadDone(false)
, _rectify_H(false)

{
    m_eventHandler = new CEventHandler();
}

cOSG::~cOSG()
{
    mViewer->setDone(true);
    Sleep(500);
    mViewer->stopThreading();

    delete mViewer;
}
void cOSG::InitOSG()
{
    //sendBuildString(_T("OSG 正在初始化..."));

    // Init different parts of OSG
    //sendBuildString(_T("正在初始化操作器..."));
    InitManipulators();

    //sendBuildString(_T("正在初始化场景..."));
    InitSceneGraph();

    //sendBuildString(_T("正在初始化相机..."));
    InitCameraConfig();

    // ------------------事件处理------------------
    //sendBuildString(_T("正在添加事件处理器..."));
    mViewer->addEventHandler(m_eventHandler);

    // ------------------相机操作器------------------
    //sendBuildString(_T("正在添加相机操作器..."));
    mViewer->setCameraManipulator(m_naviManipulator);

    // 调整初始视角
    fixInitCamera();

}

void cOSG::InitOSG(CString initModelName)
{
    // Init different parts of OSG
    //sendBuildString(_T("正在初始化操作器..."));
    InitManipulators();

    //sendBuildString(_T("正在初始化场景..."));
    //InitSceneGraph();
    ref_ptr<Group> newSceneNode = dynamic_cast<Group*>
        (osgDB::readNodeFile(CStringA(initModelName).GetBuffer(0)));
    newSceneNode->setName("Init Model");
    CMainFrame* pFrame = (CMainFrame*)AfxGetApp()->GetMainWnd();
    CTNDoc* doc = (CTNDoc*)pFrame->GetActiveDocument();
    CString dpstr = doc->m_datapath;

    // 查重名Label，修改新加的Label名，确保无重名Label
    CTNApp *app = (CTNApp *)AfxGetApp();
    app->nodeNameSet.clear();
    mRoot = new Group;
    mRoot->setName("Root");
    app->insertNodeName(L"Root");

    // 查找新场景节点中的Label并加入到nameSet中
    HWND hMainWnd = AfxGetApp()->GetMainWnd()->GetSafeHwnd();
    int initSceneChildNum = newSceneNode->getNumChildren();
    CString childiName;
    for (int i = 0; i < initSceneChildNum; i++)
    {
        ref_ptr<Group> childi = dynamic_cast<Group*>(newSceneNode->getChild(i));
        childiName = childi->getName().c_str();
        if (childiName == "Model" || childiName == "Label")
        {
            Transform* trans = childi->getChild(0)->asTransform();
            Node* node = trans->getChild(0);
            childiName = node->getName().c_str();
        }
        if (app->insertNodeName2(childiName) >= 0)
        {
            // 发送消息 更新调试信息
            ::SendMessage(hMainWnd, WM_USER_ADDMODELNAME,
                          WPARAM(childiName.GetBuffer(childiName.GetAllocLength()))
                          , (LPARAM)"Root");
        }
    }

    float r = newSceneNode->getBound().radius();
    float z = newSceneNode->getBound().center().z() - r;
    Vec3f positionAdj = Vec3f(0, 0, doc->initModelZ); // adjust zxis position
    MatrixTransform* trans = new MatrixTransform;
    trans->setName("Matrix");
    trans->setMatrix(Matrix::scale(1., 1., 1.) // adjust scale
                     *Matrix::translate(positionAdj) // adjust position
                     );
    trans->addChild(newSceneNode);
    ref_ptr<Group> initGroup = new Group;
    initGroup->setName("Model");
    initGroup->addChild(trans);
    mRoot->addChild(initGroup);

    Vec3 center(0.0f, 0.0f, 0.0f);
    float radius = 50.0f;
    float baseHeight = 0.0f;
    ref_ptr<Node> baseModel = createBase(Vec3(center.x(), center.y(), baseHeight), radius);
    baseModel->setName("BASE");
    //mRoot->addChild(baseModel.get());
    CString cstr;
    cstr = baseModel->getName().c_str();
    app->insertNodeName(cstr);

    //mRoot->addChild(mesh);

    //sendBuildString(_T("正在初始化相机..."));
    InitCameraConfig();

    // ------------------事件处理------------------
    //sendBuildString(_T("正在添加事件处理器..."));
    mViewer->addEventHandler(m_eventHandler);

    // ------------------相机操作器------------------
    //sendBuildString(_T("正在添加相机操作器..."));
    mViewer->setCameraManipulator(m_naviManipulator);

    fixInitCamera();

    // moveCameratoNode(mRoot.get());

    // 显示网格
    mViewer->addEventHandler(
        new osgGA::StateSetManipulator(
        mViewer->getCamera()->getOrCreateStateSet()));


    // 添加光源
    osg::ref_ptr<osg::StateSet> stateset = mRoot->getOrCreateStateSet();
    stateset->setMode(GL_LIGHTING, osg::StateAttribute::ON);
    stateset->setMode(GL_LIGHT2, osg::StateAttribute::ON);    // GL_LIGHT0是默认光源  
    // 设置6个光源 解决光照问题  
    osg::Vec3d ptLight;
    osg::Vec3d ptCenter = osg::Vec3d(0, 0, 0);
    double dDis = 20000.0;
    {
        ptLight = ptCenter + osg::Z_AXIS * dDis;
        osg::Node *pNodeLight = createLightSource(2, ptLight, -osg::Z_AXIS);
        pNodeLight->setName("light0");
        mRoot->addChild(pNodeLight);
    }

}

void cOSG::InitManipulators(void)
{
    m_naviManipulator = new CNaviManipulator();
    m_terrainManipulator = new TerrainManipulator();
}


void cOSG::InitSceneGraph(void)
{
    // Init the main Root Node/Group
    mRoot = new Group;
    mRoot->setName("Root");
    CTNApp *app = (CTNApp *)AfxGetApp();
    app->insertNodeName(L"Root");

    Vec3 center(0.0f, 0.0f, 0.0f);
    float radius = 50.0f;
    float baseHeight = 0.0f;
    ref_ptr<Node> baseModel = createBase(Vec3(center.x(), center.y(), baseHeight), radius);
    baseModel->setName("BASE");
    ref_ptr<Node> axixModel = createAxis();
    axixModel->setName("AXIS");

    CString cstr;

    mRoot->addChild(baseModel.get());
    cstr = baseModel->getName().c_str();
    app->insertNodeName(cstr);

    mRoot->addChild(axixModel.get());
    cstr = axixModel->getName().c_str();
    app->insertNodeName(cstr);

    // 添加光源
    osg::ref_ptr<osg::StateSet> stateset = mRoot->getOrCreateStateSet();
    stateset->setMode(GL_LIGHTING, osg::StateAttribute::ON);
    stateset->setMode(GL_LIGHT2, osg::StateAttribute::ON);    // GL_LIGHT0是默认光源  
    // 设置6个光源 解决光照问题  
    osg::Vec3d ptLight;
    osg::Vec3d ptCenter = osg::Vec3d(0, 0, 0);
    double dDis = 20000.0;
    {
        ptLight = ptCenter + osg::Z_AXIS * dDis;
        osg::Node *pNodeLight = createLightSource(2, ptLight, -osg::Z_AXIS);
        pNodeLight->setName("light0");
        mRoot->addChild(pNodeLight);
    }

    // insert 初始模型
    //ref_ptr<Group> initNode = new Group;
    //initNode->setName("init Node");
    //CMainFrame* pFrame = (CMainFrame*)AfxGetApp()->GetMainWnd();
    //CTNDoc* doc = (CTNDoc*)pFrame->GetActiveDocument();

    //CString path = doc->m_datapath;//L"D:\\OSG\\Production_1\\Data\\";
    //std::list<CString> dirList;
    //// 读取文件列表
    //getJustCurrentDir(path, dirList);
    //// 遍历读取文件并添加到节点
    //std::list<CString>::iterator FLIter;
    //CString modelName;
    //int partCnt = 0;
    //for (FLIter = dirList.begin(); FLIter != dirList.end(); FLIter++)
    //{
    //    cstr = *FLIter;
    //    modelName = path + cstr + L"\\" + cstr + L".osgb";
    //    ref_ptr<Node> osgbNode = osgDB::readNodeFile(
    //        CStringA(modelName).GetBuffer(0));
    //    if (osgbNode != NULL)
    //    {
    //        osgbNode->setName(CStringA(cstr).GetBuffer(0));
    //        initNode->addChild(osgbNode);
    //        partCnt++;
    //    }
    //}
    //float r = initNode->getBound().radius();
    //float z = initNode->getBound().center().z() - r;
    //Vec3f positionAdj = Vec3f(0, 0, doc->initModelZ); // adjust zxis position
    //MatrixTransform* trans = new MatrixTransform;
    //trans->setName("Matrix");
    //trans->setMatrix(Matrix::scale(1., 1., 1.) // adjust scale
    //                 *Matrix::translate(positionAdj) // adjust position
    //                 );
    //trans->addChild(initNode);
    //ref_ptr<Group> initGroup = new Group;
    //initGroup->setName("Init Model");
    //initGroup->addChild(trans);

    //mRoot->addChild(initGroup);
    //// cstr.Format(L"初始模型(%d)", partCnt);
    //app->insertNodeName(L"Init Model");
}

void cOSG::InitCameraConfig(void)
{
    // Local Variable to hold window size data
    RECT rect;

    // Create the viewer for this window
    mViewer = new osgViewer::Viewer();

    // Add a Stats Handler to the viewer
    mViewer->addEventHandler(new osgViewer::StatsHandler);

    mViewer->setCameraManipulator(NULL);

    // Get the current window size
    ::GetWindowRect(m_hWnd, &rect);

    // Init the GraphicsContext Traits
    ref_ptr<GraphicsContext::Traits> traits = new GraphicsContext::Traits;

    // Init the Windata Variable that holds the handle for the Window to display OSG in.
    ref_ptr<Referenced> windata = new osgViewer::GraphicsWindowWin32::WindowData(m_hWnd);
    // x64
    // ref_ptr<Referenced> windata = new osgViewer::GraphicsWindow::
    // Setup the traits parameters
    traits->x = 0;
    traits->y = 0;
    traits->width = rect.right - rect.left;
    traits->height = rect.bottom - rect.top;
    traits->windowDecoration = false;
    traits->doubleBuffer = true;
    traits->sharedContext = 0;
    traits->setInheritedWindowPixelFormat = true;
    traits->inheritedWindowData = windata;

    // Create the Graphics Context
    GraphicsContext* gc = GraphicsContext::createGraphicsContext(traits.get());

    // Init Master Camera for this View
    ref_ptr<Camera> camera = mViewer->getCamera();

    // Assign Graphics Context to the Camera
    camera->setGraphicsContext(gc);

    // Set the viewport for the Camera
    camera->setViewport(new Viewport(0, 0, traits->width, traits->height));

    // Set projection matrix and camera attribtues
    camera->setClearMask(GL_DEPTH_BUFFER_BIT | GL_COLOR_BUFFER_BIT);
    camera->setClearColor(Vec4f(0.2f, 0.2f, 0.4f, 1.0f));
    /*camera->setProjectionMatrixAsPerspective(
        30.0f, static_cast<double>(traits->width) / static_cast<double>(traits->height), 1.0, 1000.0);
        */

    // Add the Camera to the Viewer
    // mViewer->addSlave(camera.get());
    mViewer->setCamera(camera.get());

    // Add the Camera Manipulator to the Viewer

    // Set the Scene Data
    mViewer->setSceneData(mRoot.get());

    // Realize the Viewer
    mViewer->realize();
}



void cOSG::addNewModels(bool a)
{
    m_eventHandler->addModelValid = a;
}

void cOSG::addNewModels()
{
    m_eventHandler->addModelValid = true;
}

void cOSG::addEffects(bool f)
{
    m_eventHandler->addFireValid = f;
}
void cOSG::addEffects()
{
    m_eventHandler->addFireValid = true;
}

void cOSG::dontAddNewModels()
{
    m_eventHandler->addModelValid = false;
}
void cOSG::dontAddEffects()
{
    m_eventHandler->addFireValid = false;
}

void cOSG::setNewModel(CString modelname, CString nodename)
{
    m_eventHandler->m_modelname = modelname;
    if (nodename.GetLength() > 0)m_eventHandler->m_nodename = nodename;
    //AfxMessageBox(modelname.GetBuffer());
}

void cOSG::_createLabelBox()
{
    RECT rect;
    // Get the current window size
    ::GetWindowRect(m_hWnd, &rect);
    float width = rect.right - rect.left,
        height = rect.bottom - rect.top;
    osgWidget::Label* label = new osgWidget::Label("Infolabel");
    label->setFont("fonts/Vera.ttf");
    label->setFontSize(16.);
    label->setFontColor(1.0f, 1.0f, 1.0f, 1.0f);
    label->setAlignHorizontal(osgWidget::Widget::HA_CENTER);
    label->setPadding(0.0f);
    label->setWidth(width);
    label->setHeight(45.0f);
    label->setLabel("aX:0.0 aZ:0.0 pos:0.0 0.0 0.0");
    _InfoLabelBox = new osgWidget::Box("InfoLabelBox", osgWidget::Box::VERTICAL);
    _InfoLabelBox->setAnchorHorizontal(osgWidget::Window::HA_LEFT);
    _InfoLabelBox->setOrigin(0.0f, height - 60.0f);
    _InfoLabelBox->setVisibilityMode(osgWidget::Window::VM_FULL);
    _InfoLabelBox->addWidget(label);
    _InfoLabelBox->getBackground()->setColor(0.0f, 0.0f, 0.0f, 0.0f);

}

ref_ptr<Node> cOSG::createBase(const Vec3& center, float radius)
{

    int numTilesX = 10;
    int numTilesY = 10;

    float width = 2 * radius;
    float height = 2 * radius;

    Vec3 v000(center - Vec3(width*0.5f, height*0.5f, 0.0f));
    Vec3 dx(Vec3(width / ((float)numTilesX), 0.0, 0.0f));
    Vec3 dy(Vec3(0.0f, height / ((float)numTilesY), 0.0f));

    // fill in vertices for grid, note numTilesX+1 * numTilesY+1...
    Vec3Array* coords = new Vec3Array;
    int iy;
    for (iy = 0; iy <= numTilesY; ++iy)
    {
        for (int ix = 0; ix <= numTilesX; ++ix)
        {
            coords->push_back(v000 + dx*(float)ix + dy*(float)iy);
        }
    }

    //Just two colours - black and white.
    Vec4Array* colors = new Vec4Array;
    colors->push_back(Vec4(1.0f, 1.0f, 1.0f, 1.0f)); // white
    colors->push_back(Vec4(0.0f, 1.0f, 0.0f, 1.0f)); // black

    ref_ptr<DrawElementsUShort> whitePrimitives = new DrawElementsUShort(GL_QUADS);
    ref_ptr<DrawElementsUShort> blackPrimitives = new DrawElementsUShort(GL_QUADS);

    int numIndicesPerRow = numTilesX + 1;
    for (iy = 0; iy < numTilesY; ++iy)
    {
        for (int ix = 0; ix < numTilesX; ++ix)
        {
            DrawElementsUShort* primitives = ((iy + ix) % 2 == 0) ? whitePrimitives.get() : blackPrimitives.get();
            primitives->push_back(ix + (iy + 1)*numIndicesPerRow);
            primitives->push_back(ix + iy*numIndicesPerRow);
            primitives->push_back((ix + 1) + iy*numIndicesPerRow);
            primitives->push_back((ix + 1) + (iy + 1)*numIndicesPerRow);
        }
    }

    // set up a single normal
    Vec3Array* normals = new Vec3Array;
    normals->push_back(Vec3(0.0f, 0.0f, 1.0f));

    Geometry* geom = new Geometry;
    geom->setVertexArray(coords);

    geom->setColorArray(colors, Array::BIND_PER_PRIMITIVE_SET);

    geom->setNormalArray(normals, Array::BIND_OVERALL);

    geom->addPrimitiveSet(whitePrimitives.get());
    geom->addPrimitiveSet(blackPrimitives.get());

    ref_ptr<Geode> geode = new Geode;
    geode->addDrawable(geom);

    return geode;
}
ref_ptr<Geode> cOSG::createAxis()
{
    ref_ptr<Geode> geode(new Geode());
    ref_ptr<Geometry> geometry(new Geometry());

    ref_ptr<Vec3Array> vertices(new Vec3Array());
    vertices->push_back(Vec3(0.0, 0.0, 0.0));
    vertices->push_back(Vec3(1.0, 0.0, 0.0));
    vertices->push_back(Vec3(0.0, 0.0, 0.0));
    vertices->push_back(Vec3(0.0, 2.0, 0.0));
    vertices->push_back(Vec3(0.0, 0.0, 0.0));
    vertices->push_back(Vec3(0.0, 0.0, 3.0));
    geometry->setVertexArray(vertices.get());

    ref_ptr<Vec4Array> colors(new Vec4Array());
    colors->push_back(Vec4(1.0f, 0.0f, 0.0f, 1.0f));
    colors->push_back(Vec4(1.0f, 0.0f, 0.0f, 1.0f));
    colors->push_back(Vec4(0.0f, 1.0f, 0.0f, 1.0f));
    colors->push_back(Vec4(0.0f, 1.0f, 0.0f, 1.0f));
    colors->push_back(Vec4(0.0f, 0.0f, 1.0f, 1.0f));
    colors->push_back(Vec4(0.0f, 0.0f, 1.0f, 1.0f));
    geometry->setColorArray(colors.get(), Array::BIND_PER_VERTEX);
    geometry->addPrimitiveSet(new DrawArrays(PrimitiveSet::LINES, 0, 6));

    geode->addDrawable(geometry.get());
    geode->getOrCreateStateSet()->setMode(GL_LIGHTING, false);
    return geode;
}

void cOSG::stopThread()
{
    mViewer->setSceneData(NULL);
    mViewer->setDone(true);
    Sleep(100);
    mViewer->stopThreading();
}

void cOSG::rerunThread()
{
    mViewer->setDone(false);
    Sleep(100);
    mViewer->startThreading();
}

void cOSG::setRoot(ref_ptr<Group> newSceneNode)
{
    mRoot = newSceneNode;
}

void cOSG::fixInitCamera()
{
    Vec3d eye(47., -124., 150.), center(0., 0., 0.), up(0., 0., 10);
    m_naviManipulator->setDistance(200.);
    m_naviManipulator->setTransformation(eye, center, up);
}

void cOSG::editLabelName(CString tarLabel, CString name)
{
    if (name.Find(L"$", 0) > -1)
    {
        AfxMessageBox(L"标签名不能包含$字符!");
        return;
    }
    int igChildNum = mRoot->getNumChildren();
    for (int i = 0; i < igChildNum; i++)
    {
        Group* dg = dynamic_cast<Group*>(mRoot->getChild(i));
        if (dg == NULL)continue;
        if (dg->getName() == "Label")
        {
            Transform* mt = dg->getChild(0)->asTransform();
            Node* node = mt->getChild(0);
            CString modelName;
            modelName = node->getName().c_str();
            if (modelName == tarLabel)
            {
                node->setName(CStringA(name.GetBuffer(0)));
                HWND hMainWnd = AfxGetApp()->GetMainWnd()->GetSafeHwnd();
                SendMessage(hMainWnd, WM_USER_EDITMODELLABEL,
                            WPARAM(tarLabel.GetBuffer(tarLabel.GetAllocLength()))
                            , (LPARAM)name.GetBuffer(name.GetAllocLength()));
            }
        }
    }
}

void cOSG::deleteLabel(CString tarLabel)
{
    int igChildNum = mRoot->getNumChildren();
    for (int i = 0; i < igChildNum; i++)
    {
        Group* dg = dynamic_cast<Group*>(mRoot->getChild(i));
        if (dg == NULL)continue;
        if (dg->getName() == "Label")
        {
            Transform* mt = dg->getChild(0)->asTransform();
            Node* node = mt->getChild(0);
            CString modelName;
            modelName = node->getName().c_str();
            if (modelName == tarLabel)
            {
                mRoot->removeChild(i);
                break;
            }
        }
    }
}

Node * cOSG::getNodeByName(ref_ptr<Group> mRoot, std::string nodeName)
{
    CfindNodeVisitor findNV(nodeName);
    mRoot->accept(findNV);
    return findNV.getFirst();
};

void cOSG::moveCameratoNode(std::string nodeName)
{
    Node * tarNode = getNodeByName(mRoot, nodeName);
    moveCameratoNode(tarNode);
}

void cOSG::moveCameratoNode(Node* tarNode)
{
    if (!tarNode)
    {
        return;
    }
    Vec3d eye, center, up, oldeye, oldcenter, oldup;
    m_naviManipulator->getTransformation(oldeye, oldcenter, oldup);
    Vec3d pos(tarNode->getBound().center())
        , delta = (pos - oldcenter);
    up = oldup;
    eye = oldeye + (pos - oldcenter);
    eye.set(eye.x(), eye.y(), oldeye.z());
    center = pos;
    m_naviManipulator->setTransformation(eye, center, up);
}

void cOSG::moveCameratoLabel(CString cstrLabel)
{
    int igChildNum = mRoot->getNumChildren();
    ref_ptr<Group> tarLabel = NULL;
    for (int i = 0; i < igChildNum; i++)
    {
        Group* dg = dynamic_cast<Group*>(mRoot->getChild(i));
        if (dg == NULL)continue;
        if (dg->getName() == "Label")
        {
            Transform* mt = dg->getChild(0)->asTransform();
            Node* node = mt->getChild(0);
            CString modelName;
            modelName = node->getName().c_str();
            if (modelName == cstrLabel)
            {
                tarLabel = dynamic_cast<Group*>(mRoot->getChild(i));
                break;
            }
        }
    }
    if (tarLabel)
    {
        Vec3d eye, center, up, oldeye, oldcenter, oldup;
        m_naviManipulator->getTransformation(oldeye, oldcenter, oldup);
        Vec3d pos(tarLabel->getBound().center())
            , delta = (pos - oldcenter);
        up = oldup;
        eye = oldeye + (pos - oldcenter);
        eye.set(eye.x(), eye.y(), oldeye.z());
        center = pos;
        m_naviManipulator->setTransformation(eye, center, up);
        // m_naviManipulator->setCenter(0.5, delta.x(), delta.y());

    }
}

void cOSG::getJustCurrentDir(CString path, std::list<CString>& files)
{
    CFileFind finder;
    BOOL working = finder.FindFile(path + L"*.*");
    while (working)
    {
        working = finder.FindNextFile();
        if (finder.IsDots())
            continue;
        if (finder.IsDirectory())
        {
            //FindAllFile(finder.GetFilePath(), filenames, count);
            CString filename = finder.GetFileTitle();
            if (filename.Left(6) == L"Tile_+")
            {
                files.push_back(filename);
            }
        }
        else
        {
            CString filename = finder.GetFileTitle();
        }
    }
    finder.Close();
}

int cOSG::getNumInRect(ref_ptr<Vec3Array> triPoints, ref_ptr<Vec3Array> rect
                       , std::vector<int>& triIndex)
{
    assert(triPoints);
    UINT triPointsNum = triPoints->size();
    assert(triPointsNum >= 3);
    assert(triPointsNum % 3 == 0);
    UINT triNum = triPointsNum / 3;
    assert(rect);
    assert(rect->size() == 2);

    int numInRect = 0;
    ref_ptr<Vec3Array> oneTriPoints = new Vec3Array;
    for (UINT i = 0; i < triNum; i += 3)
    {
        oneTriPoints->push_back(triPoints->at(i));
        oneTriPoints->push_back(triPoints->at(i + 1));
        oneTriPoints->push_back(triPoints->at(i + 2));
        if (isInRect(oneTriPoints, rect))
        {
            numInRect++;
            triIndex.push_back(i);
        }
    }

    return numInRect;
}

bool cOSG::isInRect(ref_ptr<Vec3Array> oneTriPoints, ref_ptr<Vec3Array> rect)
{
    assert(oneTriPoints);
    UINT triPointsNum = oneTriPoints->size();
    assert(triPointsNum == 3);

    int innerPointsNum = 0;
    float left = rect->at(0).x()
        , right = rect->at(1).x()
        , top = rect->at(0).y()
        , bottom = rect->at(1).y();
    Vec3 triPoint;
    for (int i = 0; i < 3; i++)
    {
        triPoint = oneTriPoints->back();
        oneTriPoints->pop_back();
        if (triPoint.x() >= left && triPoint.x() <= right
            && triPoint.y() >= bottom && triPoint.y() <= top)
        {
            innerPointsNum++;
        }
    }

    return innerPointsNum >= 3;
}

Node* cOSG::creatMesh(ref_ptr<Vec3Array> triPointsInRect
                      , ref_ptr<Vec2Array> triTexInRect)
{
    ref_ptr<Geode> geode = new Geode();
    ref_ptr<Geometry> triGeom = new Geometry();
    // 顶点
    ref_ptr<Vec3Array> vertices = triPointsInRect;      // 网格顶点
    triGeom->setVertexArray(vertices.get());
    triGeom->addPrimitiveSet(new DrawArrays(PrimitiveSet::TRIANGLES, 0, vertices->size()));
    // 纹理坐标
    ref_ptr<Vec2Array> textArray = triTexInRect;
    triGeom->setTexCoordArray(0, textArray);
    // 法线
    ref_ptr<Vec3Array> normals = new Vec3Array();  // 法线
    normals->push_back(Z_AXIS);
    triGeom->setNormalArray(normals);
    triGeom->setNormalBinding(Geometry::BIND_OVERALL);
    // 颜色
    // ref_ptr<Vec4Array> color = new Vec4Array;
    // color->push_back(Vec4(1, 0.8, 0, 1));
    // triGeom->setColorArray(color);
    // triGeom->getOrCreateStateSet()->setAttribute(new LineWidth(2), StateAttribute::ON);

    geode->addDrawable(triGeom);

    return geode.release();
}


void cOSG::RectifyH()
{
    _rectify_H = ~_rectify_H;
    m_eventHandler->RectifyH(_rectify_H);
}

///////////////////////////////// Render /////////////////////////////////
void cOSG::PreFrameUpdate()
{}

void cOSG::PostFrameUpdate()
{}

void cOSG::Render(void* ptr)
{
    cOSG* osg = (cOSG*)ptr;

    osgViewer::Viewer* viewer = osg->getViewer();

    // You have two options for the main viewer loop
    //      viewer->run()   or
    //      while(!viewer->done()) { viewer->frame(); }

    //viewer->run();
    while (!osg->osgThreadDone && !viewer->done())
    {
        osg->PreFrameUpdate();
        viewer->frame();
        osg->PostFrameUpdate();
        Sleep(10);         // Use this command if you need to allow other processes to have cpu time
    }

    // For some reason this has to be here to avoid issue:
    // if you have multiple OSG windows up
    // and you exit one then all stop rendering
    AfxMessageBox(_T("Exit Rendering Thread"));

    _endthread();
}

CRenderingThread::CRenderingThread(cOSG* ptr)
    : OpenThreads::Thread(), _ptr(ptr), _done(false)
{}

CRenderingThread::~CRenderingThread()
{
    _done = true;
    if (isRunning())
    {
        cancel();
        join();
    }
}

void CRenderingThread::run()
{
    if (!_ptr)
    {
        _done = true;
        return;
    }

    osgViewer::Viewer* viewer = _ptr->getViewer();
    do
    {
        _ptr->PreFrameUpdate();
        viewer->frame();
        _ptr->PostFrameUpdate();
    } while (!testCancel() && !viewer->done() && !_done);
}