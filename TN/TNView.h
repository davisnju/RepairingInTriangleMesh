
// TNView.h : CTNView 类的接口
//

#pragma once

#include "MFC_OSG.h"
#include "TNDoc.h"

class CTNView : public CView
{
protected: // 仅从序列化创建
    CTNView();
    DECLARE_DYNCREATE(CTNView)

    // 特性
public:
    CTNDoc* GetDocument() const;

    //核心osg对象
    cOSG* mOSG;
    //线程句柄
    HANDLE mThreadHandle;

    // 各项工具
    
    // 操作
public:

    bool CTNView::saveScene(CString path, int cfm);
    void CTNView::loadScene(CString filePath);

    CString getProjectionMatrixAsPerspective()
    {
        CString cstr;
        double fovy, aspectRatio, z1, z2;
        mOSG->getViewer()->getCamera()->getProjectionMatrixAsPerspective(fovy, aspectRatio, z1, z2);
        //mOSG->getViewer()->getCamera()->setProjectionMatrixAsPerspective(fovy, abs(aspectRatio), z1, z2);
        cstr.Format(_T("%f, %f, %f, %f"), fovy, aspectRatio, z1, z2);
        return cstr;
    }

    void setNewModel(CString modelname)
    {
        mOSG->setNewModel(modelname);
    };

    // 重写
public:
    virtual void OnDraw(CDC* pDC);  // 重写以绘制该视图
    virtual BOOL PreCreateWindow(CREATESTRUCT& cs);
protected:

    // 实现
public:
    virtual ~CTNView();
#ifdef _DEBUG
    virtual void AssertValid() const;
    virtual void Dump(CDumpContext& dc) const;
#endif

protected:

    // 生成的消息映射函数
protected:
    afx_msg void OnFilePrintPreview();
    afx_msg void OnRButtonUp(UINT nFlags, CPoint point);
    afx_msg void OnContextMenu(CWnd* pWnd, CPoint point);
    DECLARE_MESSAGE_MAP()
public:
    afx_msg int OnCreate(LPCREATESTRUCT lpCreateStruct);
    virtual void OnInitialUpdate();
    afx_msg void OnMouseMove(UINT nFlags, CPoint point);
    afx_msg BOOL OnSetCursor(CWnd* pWnd, UINT nHitTest, UINT message);

    afx_msg void OnOsgPan();
    afx_msg void OnOsgOrbit();
    afx_msg void OnOsgSelect();

    afx_msg void OnOsgAddmd();
    afx_msg void OnOsgAddef();
    afx_msg void OnOsgRotate();
    afx_msg void OnOsgTrans();
    afx_msg void OnOsgScale();

    afx_msg void OnDestroy();
    afx_msg BOOL OnMouseWheel(UINT nFlags, short zDelta, CPoint pt);
    afx_msg void OnOsgAddlabel();
};

#ifndef _DEBUG  // TNView.cpp 中的调试版本
inline CTNDoc* CTNView::GetDocument() const
{
    return reinterpret_cast<CTNDoc*>(m_pDocument);
}
#endif

