
// MainFrm.h : CMainFrame 类的接口
//

#pragma once
#include "NodeView.h"
#include "ClassView.h"
#include "OutputWnd.h"
#include "PropertiesWnd.h"

#include "TNApp.h"


class CMainFrame : public CFrameWndEx
{

protected: // 仅从序列化创建
    CMainFrame();
    DECLARE_DYNCREATE(CMainFrame)

    // 特性
public:

    CString m_curLabel;

    // 操作
public:

    // 节点视图
    void clearNodeTree()
    {
        m_wndNodeView.clearNodeTree();
    };

    void insertRootNodeName(CString cstr);
    void insertNodeNameToRoot(CString cstr, UINT a, UINT b);
    void insertNameToParent(CString newName, CString parent);


    // 属性窗口
    void setModelProp(CString cstr);
    void SetManipulatorProperties(const float c1, const float c2, const float c3,
                                  const float q1, const float q2, const float q3, const float q4,
                                  const float d
                                  )
    {
        /*
        // _center
        m_wndProperties.m_wndPropList.GetProperty(2)->GetSubItem(0)->SetValue(c1);
        m_wndProperties.m_wndPropList.GetProperty(2)->GetSubItem(1)->SetValue(c2);
        m_wndProperties.m_wndPropList.GetProperty(2)->GetSubItem(2)->SetValue(c3);
        //_rotation
        m_wndProperties.m_wndPropList.GetProperty(3)->GetSubItem(0)->SetValue(q1);
        m_wndProperties.m_wndPropList.GetProperty(3)->GetSubItem(1)->SetValue(q2);
        m_wndProperties.m_wndPropList.GetProperty(3)->GetSubItem(2)->SetValue(q3);
        m_wndProperties.m_wndPropList.GetProperty(3)->GetSubItem(3)->SetValue(q4);
        //_distance
        m_wndProperties.m_wndPropList.GetProperty(4)->GetSubItem(0)->SetValue(d);
        */
    };

    void setDebugInfo(CString cstr)
    {
        // debug
        m_wndProperties.m_wndPropList.GetProperty(5)->GetSubItem(0)
            ->SetValue(cstr.GetBuffer());
    };


    // 输出窗口
    void clearBuildString()
    {
        m_wndOutput.clearBuildString();
    };
    void addBuildString(CString cstr)
    {
        m_wndOutput.addBuildString(cstr);
    };
    void clearDebugdString()
    {
        m_wndOutput.clearDebugdString();
    };
    void addDebugString(CString cstr)
    {
        m_wndOutput.addDebugString(cstr);
    };
    void clearFindString()
    {
        m_wndOutput.clearFindString();
    };
    void addFindString(CString cstr)
    {
        m_wndOutput.addFindString(cstr);
    };

    // 重写
public:
    virtual BOOL PreCreateWindow(CREATESTRUCT& cs);
    virtual BOOL LoadFrame(UINT nIDResource, DWORD dwDefaultStyle = WS_OVERLAPPEDWINDOW | FWS_ADDTOTITLE, CWnd* pParentWnd = NULL, CCreateContext* pContext = NULL);


    // 实现
public:
    virtual ~CMainFrame();
#ifdef _DEBUG
    virtual void AssertValid() const;
    virtual void Dump(CDumpContext& dc) const;
#endif

protected:  // 控件条嵌入成员
    CMFCMenuBar       m_wndMenuBar;
    CMFCToolBar       m_wndToolBar;
    CMFCStatusBar     m_wndStatusBar;
    CMFCToolBarImages m_UserImages;
    CNodeView         m_wndNodeView;
    //CClassView        m_wndClassView;
    COutputWnd        m_wndOutput;
    CPropertiesWnd    m_wndProperties;

    // 生成的消息映射函数
protected:
    afx_msg int OnCreate(LPCREATESTRUCT lpCreateStruct);
    afx_msg void OnViewCustomize();
    afx_msg LRESULT OnToolbarCreateNew(WPARAM wp, LPARAM lp);
    afx_msg void OnApplicationLook(UINT id);
    afx_msg void OnUpdateApplicationLook(CCmdUI* pCmdUI);
    afx_msg void OnSettingChange(UINT uFlags, LPCTSTR lpszSection);
    DECLARE_MESSAGE_MAP()

    BOOL CreateDockingWindows();
    void SetDockingWindowIcons(BOOL bHiColorIcons);
public:
    afx_msg void OnUpdateOsgOrbit(CCmdUI *pCmdUI);
    afx_msg void OnUpdateOsgPan(CCmdUI *pCmdUI);
    afx_msg void OnUpdateOsgSelect(CCmdUI *pCmdUI);

    // 消息处理函数
    // 设置节点视图
    afx_msg LRESULT OnHandleUpdateNodeView(WPARAM wParam, LPARAM lParam);
    afx_msg LRESULT OnEditNodeView(WPARAM wParam, LPARAM lParam);
    // 设置属性
    afx_msg LRESULT OnHandleSetProp(WPARAM wParam, LPARAM lParam);
    // 添加模型属性信息
    afx_msg LRESULT OnHandleAddLabelProp(WPARAM wParam, LPARAM lParam);
    // 输出窗口显示build信息
    afx_msg LRESULT OnHandleOutputBuildStr(WPARAM wParam, LPARAM lParam);

    afx_msg void OnUpdateOsgScale(CCmdUI *pCmdUI);
    afx_msg void OnUpdateOsgAddmd(CCmdUI *pCmdUI);
    afx_msg void OnUpdateOsgAddef(CCmdUI *pCmdUI);
    afx_msg void OnUpdateOsgRotate(CCmdUI *pCmdUI);
    afx_msg void OnUpdateOsgTrans(CCmdUI *pCmdUI);
    afx_msg void OnUpdateOsgAddlabel(CCmdUI *pCmdUI);
    void deleteLabel(CString curLabel);

    afx_msg LRESULT OnUserDbclklabel(WPARAM wParam, LPARAM lParam);
    afx_msg void OnClose();
    afx_msg void OnRectifyH();
};


