/*!
 * commonNodeVisitor.cpp
 * date: 2017/05/02 17:45
 *
 * author: dav1sNJU
 *
 * brief:
 *
 * TODO: long description
 *
 */
#include "stdafx.h"
#include "findNodeVisitor.h"


CfindNodeVisitor::CfindNodeVisitor() :
osg::NodeVisitor(TRAVERSE_ALL_CHILDREN), searchNodeName()
{
}

CfindNodeVisitor::~CfindNodeVisitor() 
{
}


CfindNodeVisitor::CfindNodeVisitor(const std::string &searchName) :
osg::NodeVisitor(TRAVERSE_ALL_CHILDREN), searchNodeName(searchName) 
{
}

void CfindNodeVisitor::setNameToFind(const std::string &searchName)
{
    searchNodeName = searchName;
    foundNodeList.clear();
}

void CfindNodeVisitor::apply(osg::Node &searchNode)
{
    if (searchNode.getName() == searchNodeName)
    {
        foundNodeList.push_back(&searchNode);
    } 
    traverse(searchNode);
}

osg::Node* CfindNodeVisitor::getFirst()
{
    if (foundNodeList.empty())
    {
        return NULL;
    }
    return *(foundNodeList.begin());
}