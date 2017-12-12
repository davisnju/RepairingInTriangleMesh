#include "osg_utils.h"
#include "MeshNodeVisitor.h"

vector<Vec3> analyzeNormals(Group *group)
{
    vector<Vec3> res;
    ofstream ofile;
    ofile.open("normals.txt");
    CMeshNodeVisitor meshnv;
    group->accept(meshnv);
    // 得到各个三角网格的顶点坐标
    ref_ptr<Vec3Array> triPoints = meshnv.getTriPoints();
    int n = triPoints->size();
    for (int i = 0; i < n; i += 3)
    {
        Vec3 normal = calcNormal(triPoints->at(i),
                                 triPoints->at(i + 1),
                                 triPoints->at(i + 2));
        ofile << normal.x() << "," << normal.y() << "," << normal.z() << endl;
        res.push_back(normal);
    }
    ofile.close();
    return res;
}

Vec3 calcNormal(const Vec3& a, const Vec3& b, const Vec3& c)
{
    vector<Vec3> vv;
    vv.push_back(a);
    vv.push_back(b);
    vv.push_back(c);
    sort(vv.begin(), vv.end(), point3compare);
    Vec3 A(vv[0] - vv[1]), B(vv[1] - vv[2]);
    Vec3 n = A ^ B;
    n.normalize();
    return n;
}

bool point3compare(const Vec3& a, const Vec3& b)
{
    return a.x() < b.x() || (fabs(a.x() - b.x()) < 0.000001 && a.y()< b.y())
        || (fabs(a.x() - b.x()) < 0.000001 && fabs(a.y() - b.y()) < 0.000001 && a.z() < b.z());
}


