#include <queue>
#include <list>
using namespace std;
// 三维坐标点 结构
typedef struct ST_POINT
{
    float fX;
    float fY;
    float fZ;
}ST_POINT_t;

// 边 结构
typedef struct ST_EDGE
{
    int nV1Ind;
    int nV2Ind;
}ST_EDGE_t;

// 三角面片 结构
typedef struct ST_FACET
{
    int nV1Ind;    // 顶点索引
    int nV2Ind;    // 顶点索引
    int nV3Ind;    // 顶点索引
}ST_FACET_t;


// 边界边 结构
typedef struct ST_HOLE_EDGE
{
    int nEInd;    // 边索引
    int nFInd;    // 邻接三角面片索引
}ST_HOLE_EDGE_t;

queue<int> queueE;
list<int> listE;
listE.clear()
while != true
{
    ;
    ;
    ;
    if == true
    {
        if ==    // 该条边界形成闭环
        {

        }
        else
        {
            return;
        }
    }
    else
    {
        ;  // 在边界集 中查//找以 的终点为起点的边
        if    is NULL
        {
            if ==   // 该条边界形成闭环
            {

            }
            else
            {
                return;
            }

        }
    }
}
