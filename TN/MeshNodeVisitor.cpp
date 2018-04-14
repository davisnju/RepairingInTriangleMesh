#include "stdafx.h"

#include "MeshNodeVisitor.h"

#include <osg/Drawable>
#include <osg/Geode>
#include <osg/Geometry>
#include <osg/MatrixTransform>
#include <osg/Array>

void CMeshNodeVisitor::apply(Geode &geode)
{
    //计算当前geode节点对应的世界变换矩阵，用来计算geode中顶点对应的世界坐标
    osg::Matrix geodeMatrix = osg::computeLocalToWorld(getNodePath());

    unsigned int drwnum = geode.getNumDrawables();
    for (unsigned int i = 0; i < drwnum; i++)
    {
        ref_ptr<Geometry>geometry = geode.getDrawable(i)->asGeometry();
        if (!geometry)
            continue;

        for (unsigned int n = 0; n < geometry->getNumPrimitiveSets(); ++n)
        {
            PrimitiveSet* ps = geometry->getPrimitiveSet(n);
            if (!ps)
                continue;
            //获取顶点数组  
            ref_ptr<Vec3Array> va = dynamic_cast<Vec3Array*>(geometry->getVertexArray());
            //获取纹理数组  
            ref_ptr<Vec2Array> tex = dynamic_cast<Vec2Array*>(geometry->getTexCoordArray(0));

            if ((PrimitiveSet::DrawElementsUIntPrimitiveType == ps->getType()) && (PrimitiveSet::TRIANGLES == ps->getMode()))
            {
                ref_ptr<DrawElementsUInt>deui = dynamic_cast<DrawElementsUInt*>(ps);
                const unsigned indexNum = deui->getNumIndices(); //indexNum获取了索引的个数  216
                for (unsigned int m = 0; m < indexNum; m++)
                {
                    m_TriPoints->push_back(va->at(deui->at(m))*geodeMatrix);//获取索引位置的顶点  
                    if (NULL != tex)
                    {
                        m_TriTexCoordArray->push_back(tex->at(deui->at(m)));//获取索引位置的纹理坐标
                    }
                }
            }
            else
            {
                AfxMessageBox(L"模型绘制方式不是三角形！");
            }
        }
    }
    traverse(geode);
}



CMeshNodeVisitor::~CMeshNodeVisitor()
{}
