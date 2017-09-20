#pragma once
#include <osg/NodeVisitor>
#include <osg/Drawable>
#include <osg/Geometry>
#include <osg/MatrixTransform>

using namespace osg;

class CMeshNodeVisitor :
    public NodeVisitor
{
public:
    //构造函数    
    CMeshNodeVisitor() :NodeVisitor(NodeVisitor::TRAVERSE_ALL_CHILDREN)
    {
        m_TriPoints = new Vec3Array;   //定义数组，用于保存索引号对应的顶点  
        m_TriTexCoordArray = new Vec2Array;
    }
    ~CMeshNodeVisitor();

    //重载MatrixTransform节点的apply函数  
    virtual void apply(MatrixTransform &node)
    {
        traverse(node);
    }

    //重载group的apply()函数  
    virtual void apply(Group &group)
    {
        traverse(group);
    }

    //重载Geode的apply()函数，获取对应索引号的顶点数组m_TriPoints，三角形索引数组triangle和三角形中心数组centerPoint  
    void CMeshNodeVisitor::apply(Geode &geode);

public:

    ref_ptr<Vec3Array> getTriPoints()
    {
        return m_TriPoints.release();
    }
    ref_ptr<Vec2Array> getTriTexCoordArray()
    {
        return m_TriTexCoordArray.release();
    }

private:
    ref_ptr<DrawElementsUInt>deui;
    ref_ptr<Vec3Array> m_TriPoints;
    ref_ptr<Vec2Array> m_TriTexCoordArray;
};

