
#pragma once

#include <string>

class CPropertiesToolBar : public CMFCToolBar
{
public:
    virtual void OnUpdateCmdUI(CFrameWnd* /*pTarget*/, BOOL bDisableIfNoHndler)
    {
        CMFCToolBar::OnUpdateCmdUI((CFrameWnd*)GetOwner(), bDisableIfNoHndler);
    }

    virtual BOOL AllowShowOnList() const { return FALSE; }
};

class CPropertiesWnd : public CDockablePane
{
    // 构造
public:
    CPropertiesWnd();

    void AdjustLayout();

    // 特性
public:
    
    CMFCPropertyGridCtrl m_wndPropList;
    CPropertiesToolBar m_wndToolBar;

    int selModelNamePID;

    void SetVSDotNetLook(BOOL bSet)
    {
        m_wndPropList.SetVSDotNetLook(bSet);
        m_wndPropList.SetGroupNameFullWidth(bSet);
    }

    CString getModelName()
    {
        CString cpStr(
            m_wndPropList.GetProperty(0)->GetSubItem(0)->GetValue().bstrVal);
        return cpStr;
    };
    afx_msg void OnExpandAllProperties();

protected:
    CFont m_fntPropList;
    CComboBox m_wndObjectCombo;
    // CPropertiesToolBar m_wndToolBar;
    // CMFCPropertyGridCtrl m_wndPropList;
    // 实现
public:
    virtual ~CPropertiesWnd();

protected:
    afx_msg int OnCreate(LPCREATESTRUCT lpCreateStruct);
    afx_msg void OnSize(UINT nType, int cx, int cy);
    afx_msg void OnUpdateExpandAllProperties(CCmdUI* pCmdUI);
    afx_msg void OnSortProperties();
    afx_msg void OnUpdateSortProperties(CCmdUI* pCmdUI);
    afx_msg void OnAddLabelProperties();
    afx_msg void OnUpdateLabelProperties(CCmdUI* pCmdUI);
    afx_msg void OnProperties2();
    afx_msg void OnUpdateProperties2(CCmdUI* pCmdUI);
    afx_msg void OnSetFocus(CWnd* pOldWnd);
    afx_msg void OnSettingChange(UINT uFlags, LPCTSTR lpszSection);

    afx_msg void OnLButtonDblClk(UINT nFlags, CPoint point);
    afx_msg LRESULT OnPropertyChanged(__in WPARAM wparam, __in LPARAM lparam);
    DECLARE_MESSAGE_MAP()

    void InitPropList();
    void SetPropListFont();

    int m_nComboHeight;
public:
    afx_msg void OnProperties3();
    afx_msg void OnUpdateProperties3(CCmdUI *pCmdUI);
    afx_msg void OnLabelEditprop();
    afx_msg void OnLabelDel();
    afx_msg void OnLabelDelprop();
};

