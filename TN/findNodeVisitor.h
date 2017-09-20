/*!
 * findNodeVisitor.h
 * date: 2017/05/02 17:43
 *
 * author: dav1sNJU
 *
 * brief: 
 *
 *
*/
#pragma once
#include <osg/NodeVisitor>
#include <osg/Drawable>
#include <osg/Geometry>
#include <osg/MatrixTransform>

using namespace osg;

typedef std::vector<osg::Node*> nodeListType;

class CfindNodeVisitor :
    public NodeVisitor
{
public:
    // 默认的构造函数，查找节点名为空，遍历类型为所有子节点 
    CfindNodeVisitor();
    ~CfindNodeVisitor();
    // 带节点名的构造函数，查找节点名为searchName遍历类型为所有子节点 
    CfindNodeVisitor(const std::string &searchName); 
    // 将与所查找节点名匹配的节点添加到节点列表 
    virtual void apply(osg::Node &searchNode); 
    // 定义用户查找的节点名  
    void setNameToFind(const std::string &searchName); 
    // 返回节点列表中第一个节点的指针
    osg::Node* getFirst();
    // 返回节点列表中最后一个节点的指针
    osg::Node* getLast();
    // 返回节点列表的一个引用 
    nodeListType& getNodeList() { return foundNodeList; };
    // 返回节点数目
    int getNodeCnt() { return foundNodeList.size(); };
private:
    // 查找的节点名字 
    std::string searchNodeName;
    // 节点列表  
    nodeListType foundNodeList; 
};

