#include "stdafx.h"
#include "NaviManipulator.h"

#include <osgViewer/Viewer>
#include <osgUtil/LineSegmentIntersector>
#include <osg/io_utils>
#include <osgFX/Scribe>
#include <osgDB/Registry>
#include <osg/ShapeDrawable>

#include "MeshNodeVisitor.h"
#include "TNApp.h"
#include "MainFrm.h"
#include "TNDoc.h"

using namespace osg;
using namespace osgGA;


/// Constructor.
CNaviManipulator::CNaviManipulator(int flags)
: inherited(flags)
{
    naviMode = NAVI_MODE_ORBIT;
    lCtrlDown = false;
    rCtrlDown = false;
    leftMouseDown = false;
    frameSelecting = false;
    setRotationMode(ELEVATION_AZIM);
}


/// Constructor.
CNaviManipulator::CNaviManipulator(const CNaviManipulator& tm, const CopyOp& copyOp)
: Callback(tm, copyOp),
inherited(tm, copyOp),
_previousUp(tm._previousUp)
{
    naviMode = NAVI_MODE_ORBIT;
    lCtrlDown = false;
    rCtrlDown = false;
}

void CNaviManipulator::setCenter(const double eventTimeDelta, const double dx, const double dy)
{
    performMovementMiddleMouseButton(eventTimeDelta, dx, dy);
}

/** Sets the manipulator rotation mode. RotationMode is now deprecated by
osgGA::StandardManipulator::setVerticalAxisFixed() functionality,
that is used across StandardManipulator derived classes.*/
void CNaviManipulator::setRotationMode(CNaviManipulator::RotationMode mode)
{
    setVerticalAxisFixed(mode == ELEVATION_AZIM);
}


/** Returns the manipulator rotation mode.*/
CNaviManipulator::RotationMode CNaviManipulator::getRotationMode() const
{
    return getVerticalAxisFixed() ? ELEVATION_AZIM : ELEVATION_AZIM_ROLL;
}


void CNaviManipulator::setNode(Node* node)
{
    inherited::setNode(node);

    // update model size
    if (_flags & UPDATE_MODEL_SIZE)
    {
        if (_node.valid())
        {
            setMinimumDistance(clampBetween(_modelSize * 0.001, 0.00001, 1.0));
            OSG_INFO << "CNaviManipulator: setting _minimumDistance to "
                << _minimumDistance << std::endl;
        }
    }
}


void CNaviManipulator::setByMatrix(const Matrixd& matrix)
{

    Vec3d lookVector(-matrix(2, 0), -matrix(2, 1), -matrix(2, 2));
    Vec3d eye(matrix(3, 0), matrix(3, 1), matrix(3, 2));

    OSG_INFO << "eye point " << eye << std::endl;
    OSG_INFO << "lookVector " << lookVector << std::endl;

    if (!_node)
    {
        _center = eye + lookVector;
        _distance = lookVector.length();
        _rotation = matrix.getRotate();
        return;
    }


    // need to reintersect with the terrain
    const BoundingSphere& bs = _node->getBound();
    float distance = (eye - bs.center()).length() + _node->getBound().radius();
    Vec3d start_segment = eye;
    Vec3d end_segment = eye + lookVector*distance;

    Vec3d ip;
    bool hitFound = false;
    if (intersect(start_segment, end_segment, ip))
    {
        OSG_INFO << "Hit terrain ok A" << std::endl;
        _center = ip;

        _distance = (eye - ip).length();

        Matrixd rotation_matrix = Matrixd::translate(0.0, 0.0, -_distance)*
            matrix*
            Matrixd::translate(-_center);

        _rotation = rotation_matrix.getRotate();

        hitFound = true;
    }

    if (!hitFound)
    {
        CoordinateFrame eyePointCoordFrame = getCoordinateFrame(eye);

        if (intersect(eye + getUpVector(eyePointCoordFrame)*distance,
            eye - getUpVector(eyePointCoordFrame)*distance,
            ip))
        {
            _center = ip;

            _distance = (eye - ip).length();

            _rotation.set(0, 0, 0, 1);

            hitFound = true;
        }
    }


    CoordinateFrame coordinateFrame = getCoordinateFrame(_center);
    _previousUp = getUpVector(coordinateFrame);

    clampOrientation();
}


void CNaviManipulator::setTransformation(const Vec3d& eye, const Vec3d& center, const Vec3d& up)
{
    if (!_node) return;

    // compute rotation matrix
    Vec3d lv(center - eye);
    _distance = lv.length();
    _center = center;

    OSG_INFO << "In compute" << std::endl;

    if (_node.valid())
    {
        bool hitFound = false;

        double distance = lv.length();
        double maxDistance = distance + 2 * (eye - _node->getBound().center()).length();
        Vec3d farPosition = eye + lv*(maxDistance / distance);
        Vec3d endPoint = center;
        for (int i = 0;
             !hitFound && i < 2;
             ++i, endPoint = farPosition)
        {
            // compute the intersection with the scene.

            Vec3d ip;
            if (intersect(eye, endPoint, ip))
            {
                _center = ip;
                _distance = (ip - eye).length();

                hitFound = true;
            }
        }
    }

    // note LookAt = inv(CF)*inv(RM)*inv(T) which is equivalent to:
    // inv(R) = CF*LookAt.

    Matrixd rotation_matrix = Matrixd::lookAt(eye, center, up);

    _rotation = rotation_matrix.getRotate().inverse();

    CoordinateFrame coordinateFrame = getCoordinateFrame(_center);
    _previousUp = getUpVector(coordinateFrame);

    clampOrientation();
}


bool CNaviManipulator::intersect(const Vec3d& start, const Vec3d& end, Vec3d& intersection) const
{
    ref_ptr<osgUtil::LineSegmentIntersector> lsi = new osgUtil::LineSegmentIntersector(start, end);

    osgUtil::IntersectionVisitor iv(lsi.get());
    iv.setTraversalMask(_intersectTraversalMask);

    _node->accept(iv);

    if (lsi->containsIntersections())
    {
        intersection = lsi->getIntersections().begin()->getWorldIntersectPoint();
        return true;
    }
    return false;
}

bool CNaviManipulator::performMovementLeftMouseButton(const double eventTimeDelta, const double dx, const double dy)
{
    if (naviMode == NAVI_MODE_PAN)
    {
        // pan model.
        return CNaviManipulator::performMovementMiddleMouseButton(eventTimeDelta, dx, dy);
    }
    else
    {
        return OrbitManipulator::performMovementLeftMouseButton(eventTimeDelta, dx, dy);
    }
}
bool CNaviManipulator::performMovementMiddleMouseButton(const double eventTimeDelta, const double dx, const double dy)
{
    // pan model.
    double scale = -0.3f * _distance * getThrowScale(eventTimeDelta);

    Matrixd rotation_matrix;
    rotation_matrix.makeRotate(_rotation);


    // compute look vector.
    Vec3d sideVector = getSideVector(rotation_matrix);

    // CoordinateFrame coordinateFrame = getCoordinateFrame(_center);
    // Vec3d localUp = getUpVector(coordinateFrame);
    Vec3d localUp = _previousUp;

    Vec3d forwardVector = localUp^sideVector;
    sideVector = forwardVector^localUp;

    forwardVector.normalize();
    sideVector.normalize();

    Vec3d dv = forwardVector * (dy*scale) + sideVector * (dx*scale);

    _center += dv;

    // need to recompute the intersection point along the look vector.

    bool hitFound = false;

    if (_node.valid())
    {
        // now reorientate the coordinate frame to the frame coords.
        CoordinateFrame coordinateFrame = getCoordinateFrame(_center);

        // need to reintersect with the terrain
        double distance = _node->getBound().radius()*0.25f;

        Vec3d ip1;
        Vec3d ip2;
        bool hit_ip1 = intersect(_center, _center + getUpVector(coordinateFrame) * distance, ip1);
        bool hit_ip2 = intersect(_center, _center - getUpVector(coordinateFrame) * distance, ip2);
        if (hit_ip1)
        {
            if (hit_ip2)
            {
                _center = (_center - ip1).length2() < (_center - ip2).length2() ?
                ip1 :
                    ip2;

                hitFound = true;
            }
            else
            {
                _center = ip1;
                hitFound = true;
            }
        }
        else if (hit_ip2)
        {
            _center = ip2;
            hitFound = true;
        }

        if (!hitFound)
        {
            // ??
            OSG_INFO << "CNaviManipulator unable to intersect with terrain." << std::endl;
        }

        coordinateFrame = getCoordinateFrame(_center);
        Vec3d new_localUp = getUpVector(coordinateFrame);


        Quat pan_rotation;
        pan_rotation.makeRotate(localUp, new_localUp);

        if (!pan_rotation.zeroRotation())
        {
            _rotation = _rotation * pan_rotation;
            _previousUp = new_localUp;
            //OSG_NOTICE<<"Rotating from "<<localUp<<" to "<<new_localUp<<"  angle = "<<acos(localUp*new_localUp/(localUp.length()*new_localUp.length()))<<std::endl;

            //clampOrientation();
        }
        else
        {
            OSG_INFO << "New up orientation nearly inline - no need to rotate" << std::endl;
        }
    }

    return true;
}


bool CNaviManipulator::performMovementRightMouseButton(const double eventTimeDelta, const double /*dx*/, const double dy)
{
    // zoom model
    zoomModel(dy * getThrowScale(eventTimeDelta), false);
    return true;
}


void CNaviManipulator::clampOrientation()
{
    if (!getVerticalAxisFixed())
    {
        Matrixd rotation_matrix;
        rotation_matrix.makeRotate(_rotation);

        Vec3d lookVector = -getUpVector(rotation_matrix);
        Vec3d upVector = getFrontVector(rotation_matrix);

        CoordinateFrame coordinateFrame = getCoordinateFrame(_center);
        Vec3d localUp = getUpVector(coordinateFrame);
        //Vec3d localUp = _previousUp;

        Vec3d sideVector = lookVector ^ localUp;

        if (sideVector.length() < 0.1)
        {
            OSG_INFO << "Side vector short " << sideVector.length() << std::endl;

            sideVector = upVector^localUp;
            sideVector.normalize();
        }

        Vec3d newUpVector = sideVector^lookVector;
        newUpVector.normalize();

        Quat rotate_roll;
        rotate_roll.makeRotate(upVector, newUpVector);

        if (!rotate_roll.zeroRotation())
        {
            _rotation = _rotation * rotate_roll;
        }
    }
}

bool CNaviManipulator::pick(const GUIEventAdapter& ea, GUIActionAdapter& us)
{
    if (ea.getEventType() != GUIEventAdapter::KEYUP
        && (lCtrlDown || rCtrlDown))
    {
        return OrbitManipulator::handle(ea, us);
    }

    if (ea.getEventType() == GUIEventAdapter::SCROLL)
    {
        return OrbitManipulator::handle(ea, us);
    }

    osgViewer::Viewer* viewer = NULL;
    Group* root = NULL;
    float mouseX;
    float mouseY;
    //主相机
    ref_ptr<Camera> cameraMaster = NULL;
    Matrix mvpw;
    Matrix _inverseMVPW;
    // MainFrm消息
    HWND hMainWnd = NULL;
    CString msgStr;

    switch (ea.getEventType())
    {
    case GUIEventAdapter::KEYDOWN:
        lCtrlDown = ea.getKey() == GUIEventAdapter::KEY_Control_L;
        rCtrlDown = ea.getKey() == GUIEventAdapter::KEY_Control_R;
        return true;
    case GUIEventAdapter::KEYUP:
        if (ea.getKey() == GUIEventAdapter::KEY_Control_L)
            lCtrlDown = false;
        if (ea.getKey() == GUIEventAdapter::KEY_Control_R)
            rCtrlDown = false;
        return true;
    case osgGA::GUIEventAdapter::PUSH:
        viewer = dynamic_cast<osgViewer::Viewer*>(&us);
        root = dynamic_cast<Group*>(viewer->getSceneData());
        if (!root) return false;
        mouseX = ea.getX();
        mouseY = ea.getY();
        cameraMaster = viewer->getCamera();
        mvpw = cameraMaster->getViewMatrix() * cameraMaster->getProjectionMatrix();
        if (cameraMaster->getViewport())
            mvpw.postMult(cameraMaster->getViewport()->computeWindowMatrix());
        _inverseMVPW.invert(mvpw);
        hMainWnd = AfxGetApp()->GetMainWnd()->GetSafeHwnd();
        if (ea.getButton() == GUIEventAdapter::LEFT_MOUSE_BUTTON)
        {   // 1 表示按鼠标左键  置标识位
            leftMouseDown = true;

            // 选到模型则高亮
            Group* selectedModel = root;            
            osgUtil::LineSegmentIntersector::Intersections intersections;
            if (viewer->computeIntersections(ea, intersections))
            {
                const osgUtil::LineSegmentIntersector::Intersection& hit = *intersections.begin();
                Vec3 position = hit.getWorldIntersectPoint();
                Vec3 positionlocal = hit.getLocalIntersectPoint();

                // 添加矩形框的第一个顶点
                // addPoint(root, position, 0);
                frameSelecting = true;

                m_MousePush.set(position.x(), position.y(), 0.);

                CString cstr, modelName;
                bool handleMovingModels = false;
                const NodePath& nodePath = hit.nodePath;
                for (NodePath::const_iterator nitr = nodePath.begin();
                     nitr != nodePath.end();
                     ++nitr)
                {
                    const Group* modelGroup = dynamic_cast<const Group*>(*nitr);
                    if (modelGroup && modelGroup->getName() == "Model")
                    {
                        handleMovingModels = true;
                        selectedModel = dynamic_cast<Group*>(*nitr);
                        Transform* mt = selectedModel->getChild(0)->asTransform();
                        Node* node = mt->getChild(0);

                        modelName = node->getName().c_str();
                        float x = modelGroup->getBound().center().x()
                            , y = modelGroup->getBound().center().y()
                            , z = modelGroup->getBound().center().z();
                        cstr.Format(_T("$%.6f,%.6f,%.6f"), x, y, z);
                        cstr = modelName + cstr;
                    }
                }
                HWND hMainWnd = AfxGetApp()->GetMainWnd()->GetSafeHwnd();
                
                if (handleMovingModels)
                {                    
                    return true;
                }
                else
                {
                    // 没有点击到模型
                    int rootChildNum = root->getNumChildren();
                    for (int i = 0; i < rootChildNum; i++)
                    {
                        Group * sg = dynamic_cast<Group*>(root->getChild(i));
                        if (sg->getName() == "ScribeGroup")
                        {
                            while (sg->getNumChildren() > 0)
                            {
                                root->addChild(sg->getChild(0));
                                sg->removeChild(sg->getChild(0));
                            }
                            i = -1;
                            continue;
                        }
                        osgFX::Scribe* dg = dynamic_cast<osgFX::Scribe*>(root->getChild(i));
                        if (dg == NULL)continue;
                        if (dg->getName() == "Scribe")
                        {
                            root->replaceChild(dg, dg->getChild(0));
                        }
                    }

                    // init Model
                    Group * ig = dynamic_cast<Group*>(root->getChild(0));
                    int igChildNum = ig->getNumChildren();
                    for (int i = 0; i < igChildNum; i++)
                    {
                        osgFX::Scribe* dg = dynamic_cast<osgFX::Scribe*>(ig->getChild(i));
                        if (dg == NULL)continue;
                        if (dg->getName() == "Scribe")
                        {
                            ig->replaceChild(dg, dg->getChild(0));
                        }
                    }
                    cstr = "";
                    HWND hMainWnd = AfxGetApp()->GetMainWnd()->GetSafeHwnd();

                    SendMessage(hMainWnd, WM_USER_PROP,
                                WPARAM(TRUE), (LPARAM)cstr.GetBuffer(cstr.GetAllocLength()));

                }

            }
        }
        break;    
    case GUIEventAdapter::DRAG:
        viewer = dynamic_cast<osgViewer::Viewer*>(&us);
        root = dynamic_cast<Group*>(viewer->getSceneData());
        if (!root) return false;
        mouseX = ea.getX();
        mouseY = ea.getY();
        //msgStr.Format(L"鼠标左键按下？%s Ctrl？%s 鼠标当前位置：%.2f,%.2f"
        //              , mouseX, mouseY, leftMouseDown ? "Y" : "N"
        //              , (lCtrlDown || rCtrlDown) ? "Y" : "N");
        //SendMessage(hMainWnd, WM_USER_THREADEND,
        //            WPARAM(TRUE), (LPARAM)msgStr.GetBuffer(msgStr.GetAllocLength()));

        if (leftMouseDown && !(lCtrlDown || rCtrlDown))
        {
            osgUtil::LineSegmentIntersector::Intersections intersections;
            if (viewer->computeIntersections(ea, intersections))
            {
                const osgUtil::LineSegmentIntersector::Intersection& hit = *intersections.begin();
                Vec3 position = hit.getWorldIntersectPoint();
                Vec3 positionlocal = hit.getLocalIntersectPoint();
                if (!frameSelecting)
                {
                    m_MousePush.set(position.x(), position.y(), 0.);
                    frameSelecting = true;
                }
                m_MouseRelease.set(position.x(), position.y(), 0.);
            }
            // 添加选框到root
            ref_ptr<Node> frame = createFrame(m_MousePush, m_MouseRelease);
            Group* fg = new Group;
            fg->setName("Frame");
            fg->addChild(frame);
            Group* oldfg = NULL;
            bool findFrame = false;
            int rootChildNum = root->getNumChildren();
            for (int i = 0; i < rootChildNum; i++)
            {
                oldfg = dynamic_cast<Group*>(root->getChild(i));
                if (oldfg == NULL)continue;
                if (oldfg->getName() == "Frame")
                {
                    findFrame = true;
                    break;
                }
            }
            if (!findFrame)
                root->addChild(fg);
            else
                root->replaceChild(oldfg, fg);
            return true;
        }
        break;
    case  GUIEventAdapter::RELEASE:
        if (ea.getButton() == GUIEventAdapter::LEFT_MOUSE_BUTTON)
        {
            viewer = dynamic_cast<osgViewer::Viewer*>(&us);
            root = dynamic_cast<Group*>(viewer->getSceneData());
            hMainWnd = AfxGetApp()->GetMainWnd()->GetSafeHwnd();
            if (!root) return false;
            mouseX = ea.getX();
            mouseY = ea.getY();
            if (leftMouseDown && !(lCtrlDown || rCtrlDown))
            {
                Group* fg = NULL;
                bool findFrame = false;
                int rootChildNum = root->getNumChildren();
                for (int i = 0; i < rootChildNum; i++)
                {
                    fg = dynamic_cast<Group*>(root->getChild(i));
                    if (fg == NULL)continue;
                    if (fg->getName() == "Frame")
                    {
                        findFrame = true;
                        break;
                    }
                }
                if (!findFrame)
                {
                    /*msgStr.Format(L"错误：丢失选框！");
                    SendMessage(hMainWnd, WM_USER_THREADEND,
                    WPARAM(TRUE), (LPARAM)msgStr.GetBuffer(msgStr.GetAllocLength()));
                    */
                    // return false;
                }
                else
                {
                    // 获取选框内的三角网格模型
                    ref_ptr<Group> mdg = NULL;
                    for (int i = 0; i < rootChildNum; i++)
                    {
                        mdg = dynamic_cast<Group*>(root->getChild(i));
                        if (mdg == NULL)continue;
                        if (mdg->getName() == "Model")
                        {
                            getMeshInRect(mdg, m_MousePush, m_MouseRelease);
                            break;
                        }
                    }

                    // 选中root下和矩形框相交的对象
                    Group* mg = NULL;
                    int intersectionNum = 0;
                    for (int i = 0; i < rootChildNum; i++)
                    {
                        mg = dynamic_cast<Group*>(root->getChild(i));
                        if (mg == NULL || mg == fg)continue;
                        Vec3 center = mg->getBound().center();
                        if (mg->getName() == "Model"
                            && isNodeInRect(center, m_MousePush, m_MouseRelease))
                        {
                            pickNode(root, mg);
                        }
                    }
                    // 删除选框
                    root->removeChild(fg);
                    m_MousePush.set(Vec3(0., 0., 0.));
                    m_MouseRelease.set(Vec3(0., 0., 0.));
                }

                // debugging
                // 将所有选中节点添加到ScribeGroup组，待编辑
                /*Group* scribeGroup = new Group;
                scribeGroup->setName("ScribeGroup");
                for (unsigned int i = 0; i < root->getNumChildren(); i++)
                {
                fg = dynamic_cast<Group*>(root->getChild(i));
                if (fg == NULL)continue;
                if (fg->getName() == "Scribe")
                {
                scribeGroup->addChild(fg);
                root->removeChild(fg);
                i--;
                }
                }
                root->addChild(scribeGroup);*/
            }
            leftMouseDown = false;
            frameSelecting = false;
            return true;
        }
        break;
    }
    return false;
}

ref_ptr<Node> CNaviManipulator::createFrame(const Vec3& MP, const Vec3& MR)
{
    Geometry* geom = new Geometry;
    //首先定义四个点  
    ref_ptr<Vec3Array> v = new Vec3Array();//定义一个几何体坐标集合  
    Vec3 MP1(MP), MPR(MP), MR1(MR), MRP(MR);
    MP1.set(MP.x(), MP.y(), 0.);
    MPR.set(MP.x(), MR.y(), 0.);
    MR1.set(MR.x(), MR.y(), 0.);
    MRP.set(MR.x(), MP.y(), 0.);
    v->push_back(MP1);//左下角坐标点  
    v->push_back(MPR);//右下角坐标点  
    v->push_back(MR1);//右上角坐标点  
    v->push_back(MRP);//左上角坐标点  
    geom->setVertexArray(v.get());//将坐标设置到几何体节点中  
    //定义颜色数组  
    ref_ptr<Vec4Array> c = new Vec4Array();//定义一个颜色数组颜色  
    c->push_back(Vec4(1.0, 0.0, 0.0, 0.3));//数组的四个参数分别为RGBA，其中A表示透明度  
    c->push_back(Vec4(1.0, 0.0, 0.0, 0.3));
    c->push_back(Vec4(1.0, 0.0, 0.0, 0.3));
    c->push_back(Vec4(1.0, 0.0, 0.0, 0.3));
    geom->setColorArray(c.get());//与几何体中进行关联  
    geom->setColorBinding(Geometry::BIND_PER_VERTEX);//设置绑定方式为逐点绑定。  
    //定义法线  
    ref_ptr<Vec3Array> n = new Vec3Array();//定义了一个法线绑定到该四方体中  
    n->push_back(Vec3(0.0, 0.0, 1.0));//法线为指向Z轴正半轴  
    geom->setNormalArray(n.get());//添加法线到几何体中  
    geom->setNormalBinding(Geometry::BIND_OVERALL);//将法线进行绑定  
    //设置顶点的关联方式，这里是QUADS方式，
    //总共有这么些方式：POINTS,LINES,LINE_STRIP,LINE_LOOP,
    //TRIANGLES,TRIANGLE_STRIP,TRIANGLE_FAN,QUADS,QUAD_STRIP,POLYGON  
    geom->addPrimitiveSet(
        new DrawArrays(PrimitiveSet::LINE_LOOP, 0, 4));

    ref_ptr<Geode> geode = new Geode;
    geode->addDrawable(geom);
    return geode;
}

bool CNaviManipulator::isNodeInRect(Vec3 center, Vec3d MousePush, Vec3d MouseRelease)
{
    float left, right, top, bottom, x, y;
    left = MousePush.x() < MouseRelease.x() ?
        MousePush.x() : MouseRelease.x();
    right = MousePush.x() > MouseRelease.x() ?
        MousePush.x() : MouseRelease.x();
    top = MousePush.y() > MouseRelease.y() ?
        MousePush.y() : MouseRelease.y();
    bottom = MousePush.y() < MouseRelease.y() ?
        MousePush.y() : MouseRelease.y();
    x = center.x();
    y = center.y();

    return left <= x && x <= right && bottom <= y && y <= top;
}

void CNaviManipulator::pickNode(Group* root, Group* mg)
{
    ref_ptr<osgFX::Scribe> scribe = new osgFX::Scribe();
    Vec4 wfcolor = scribe->getWireframeColor();//(r,g,b,a) = (1.,1.,1.,1.)
    wfcolor.set(1., 1., 0., 1.);
    scribe->setWireframeColor(wfcolor);
    scribe->addChild(mg);
    scribe->setName("Scribe");
    root->replaceChild(mg, scribe);

    HWND hMainWnd = AfxGetApp()->GetMainWnd()->GetSafeHwnd();
    CString n, p;
    n = mg->getName().c_str();
    p = L"Scribe";
    SendMessage(hMainWnd, WM_USER_EDITMODELNAME,
                WPARAM(n.GetBuffer(n.GetAllocLength())), (LPARAM)p.GetBuffer(p.GetAllocLength()));
    SendMessage(hMainWnd, WM_USER_ADDMODELNAME,
                WPARAM(n.GetBuffer(n.GetAllocLength())), (LPARAM)p.GetBuffer(p.GetAllocLength()));
}

void CNaviManipulator::getMeshInRect(Group* model, Vec3d MousePush, Vec3d MouseRelease)
{
    CMeshNodeVisitor* mnv = new CMeshNodeVisitor();
    model->accept(*mnv);
    // 得到各个三角网格的顶点坐标
    ref_ptr<Vec3Array> triPoints = mnv->getTriPoints();
    // 得到各个三角网格的纹理坐标
    ref_ptr<Vec2Array> textArray = mnv->getTriTexCoordArray();
    //定义一个几何体坐标集合  
    ref_ptr<Vec3Array> rect = new Vec3Array();
    float left, right, top, bottom;
    left = MousePush.x() < MouseRelease.x() ?
        MousePush.x() : MouseRelease.x();
    right = MousePush.x() > MouseRelease.x() ?
        MousePush.x() : MouseRelease.x();
    top = MousePush.y() > MouseRelease.y() ?
        MousePush.y() : MouseRelease.y();
    bottom = MousePush.y() < MouseRelease.y() ?
        MousePush.y() : MouseRelease.y();
    Vec3 LT(left, top, 0.), RB(right, bottom, 0.);
    rect->push_back(LT);//左上角坐标点  
    rect->push_back(RB);//右下角坐标点  
    std::vector<int> triIndex;
    int numInRect = getNumInRect(triPoints, rect, triIndex);
    if (!numInRect)return;
    ref_ptr<Vec3Array> triPointsInRect = new Vec3Array();
    ref_ptr<Vec2Array> triTexInRect = new Vec2Array();
    for (int i = 0; i < numInRect; i++)
    {
        triPointsInRect->push_back(triPoints->at(triIndex.at(i)));
        triPointsInRect->push_back(triPoints->at(triIndex.at(i) + 1));
        triPointsInRect->push_back(triPoints->at(triIndex.at(i) + 2));
        triTexInRect->push_back(textArray->at(triIndex.at(i)));
        triTexInRect->push_back(textArray->at(triIndex.at(i) + 1));
        triTexInRect->push_back(textArray->at(triIndex.at(i) + 2));
    }

    Node* mesh = creatMesh(triPointsInRect, triTexInRect);
    mesh->setName("Mesh");
    osg::ref_ptr<Group> meshGroup = new Group;
    meshGroup->setName("MeshGroup");
    Vec3f positionAdj = Vec3f(0, 0, 21.); // adjust zxis position
    MatrixTransform* trans = new MatrixTransform;
    trans->setName("Matrix");
    trans->setMatrix(Matrix::scale(1., 1., 1.) // adjust scale
                     *Matrix::translate(positionAdj) // adjust position
                     );
    trans->addChild(mesh);
    meshGroup->addChild(trans);
    osgDB::Registry::instance()->writeNode(*(meshGroup),
                                           "D:/OSG/Production_1/Data/meshSelected.osgb",
                                           osgDB::Registry::instance()->getOptions());

    int rootChildNum = model->getNumChildren();
    osg::ref_ptr<Group> meshNode = NULL;
    for (int i = 0; i < rootChildNum; i++)
    {
        osg::ref_ptr<Group> node = dynamic_cast<Group*>(model->getChild(i));
        if (node == NULL)continue;
        if (node->getName() == "MeshGroup")
        {
            meshNode = node;
            model->replaceChild(meshNode, meshGroup);
            break;
        }
    }
    if (meshNode == NULL)
    {
        model->addChild(meshGroup);
    }
}

int CNaviManipulator::getNumInRect(ref_ptr<Vec3Array> triPoints, ref_ptr<Vec3Array> rect, std::vector<int>& triIndex)
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

Node* CNaviManipulator::creatMesh(ref_ptr<Vec3Array> triPointsInRect, ref_ptr<Vec2Array> triTexInRect)
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

bool CNaviManipulator::isInRect(ref_ptr<Vec3Array> oneTriPoints, ref_ptr<Vec3Array> rect)
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
float CNaviManipulator::getMaxZ(ref_ptr<Vec3Array> points)
{
    int pointsNum = points->size();
    assert(pointsNum > 0);
    float zmax = points->at(0).z();
    for (int i = 1; i < pointsNum; i++)
    {
        zmax = points->at(i).z()>zmax ? points->at(i).z() : zmax;
    }
    return zmax;
}

void CNaviManipulator::addPoint(Group* root, Vec3 position, int num)
{
    ref_ptr<Node> pointNode = creatPoint(num);
    MatrixTransform* trans = new MatrixTransform;
    trans->setName("Matrix");
    float r = pointNode->getBound().radius();
    float dz = pointNode->getBound().center().z() - r;
    Vec3f positionAdj = position
        *Matrix::translate(Vec3f(0, 0, -dz / 2)); // adjust zxis position
    trans->setMatrix(Matrix::translate(positionAdj));
    trans->addChild(pointNode);
    //trans->addChild(unitSphere);
    Group* pointGroup = new Group;
    pointGroup->addChild(trans);
    pointGroup->setName(pointNode->getName());
    root->addChild(pointGroup);
}

ref_ptr<Node> CNaviManipulator::creatPoint(int i)
{
    ref_ptr<Cone>  cone = new Cone;
    ref_ptr<ShapeDrawable> shap = new ShapeDrawable(cone);
    ref_ptr<Geode> geode = new Geode;
    geode->addDrawable(shap);
    ////光照模式关闭，这样从各个方向看到的图片才是一样的  
    geode->getOrCreateStateSet()->setMode(GL_LIGHTING, StateAttribute::OFF);
    //设置圆锥高  
    cone->setHeight(0.6);
    //设置圆锥地面半径  
    cone->setRadius(0.3);

    //设置圆锥的颜色，第四个参数0.25表示不透明度，0表示完全透明，1表示完全不透明  
    shap->setColor(Vec4(1.0, 0.0, 0.0, 1));

    Quat quat;
    //根据两个向量计算四元数  
    quat.makeRotate(Z_AXIS, Vec3(0.0, 0.0, -1.0));
    cone->setRotation(quat);
    ref_ptr<Group> group = new Group;
    // 查重名Label，修改新加的Label名，确保无重名Label
    CTNApp *app = (CTNApp *)AfxGetApp();
    std::set<CString> nodeNameSet = app->nodeNameSet;
    CString modelstr;
    modelstr.Format(L"Label%d", i);
    group->setName(CStringA(modelstr).GetBuffer(0));
    group->addChild(geode);
    return group;

}
