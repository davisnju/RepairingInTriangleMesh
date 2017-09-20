#ifndef NAVI_MANIPULATOR
#define NAVI_MANIPULATOR 1

#include <osgGA/OrbitManipulator>

using namespace osg;
using namespace osgGA;

class CNaviManipulator : public OrbitManipulator
{
    typedef OrbitManipulator inherited;

public:

    int naviMode;  

    bool lCtrlDown, rCtrlDown;
    
    CNaviManipulator(int flags = DEFAULT_SETTINGS);
    CNaviManipulator(const CNaviManipulator& tm,
                     const CopyOp& copyOp = CopyOp::SHALLOW_COPY);

    META_Object(osgGA, CNaviManipulator);

    enum RotationMode
    {
        ELEVATION_AZIM_ROLL,
        ELEVATION_AZIM
    };

    void CNaviManipulator::setCenter(const double eventTimeDelta, const double dx, const double dy);

    virtual bool handle(const GUIEventAdapter& ea, GUIActionAdapter& us)
    {
        if (naviMode != NAVI_MODE_SELECT)
        {
            return OrbitManipulator::handle(ea, us);
        }
        else
        {
            // 浏览-选择模式
            return pick(ea,us);
        }
    };

    virtual void setRotationMode(RotationMode mode);
    RotationMode getRotationMode() const;

    virtual void setByMatrix(const Matrixd& matrix);

    virtual void setTransformation(const Vec3d& eye, const Vec3d& center, const Vec3d& up);

    virtual void setNode(Node* node);

protected:
    virtual bool performMovementLeftMouseButton(const double eventTimeDelta, const double dx, const double dy);
    virtual bool performMovementMiddleMouseButton(const double eventTimeDelta, const double dx, const double dy);
    virtual bool performMovementRightMouseButton(const double eventTimeDelta, const double dx, const double dy);

    bool intersect(const Vec3d& start, const Vec3d& end, Vec3d& intersection) const;
    void clampOrientation();

    bool pick(const GUIEventAdapter& ea, GUIActionAdapter& us);

    ref_ptr<Node> createFrame(const Vec3& MP, const Vec3& MR);
    bool isNodeInRect(Vec3 center, Vec3d MousePush, Vec3d MouseRelease);
    void pickNode(Group* root, Group* mg);
    void getMeshInRect(Group* root, Vec3d m_MousePush, Vec3d m_MouseRelease);
    int getNumInRect(ref_ptr<Vec3Array> triPoints, ref_ptr<Vec3Array> rect, std::vector<int>& triIndex);
    Node* creatMesh(ref_ptr<Vec3Array> triPointsInRect, ref_ptr<Vec2Array> triTexInRect);
    bool isInRect(ref_ptr<Vec3Array> oneTriPoints, ref_ptr<Vec3Array> rect);
    float getMaxZ(ref_ptr<Vec3Array> points);
    void addPoint(Group* root, Vec3 position, int num);
    ref_ptr<Node> creatPoint(int i);
    Vec3d _previousUp;

    bool leftMouseDown       //选择模式鼠标按下标识
        , frameSelecting;    //正在框选标识
    Vec3d m_MousePush;       //选择模式鼠标按下时的坐标
    Vec3d m_MouseRelease;    //选择模式鼠标抬起时的坐标
};


#endif /* NAVI_MANIPULATOR */
