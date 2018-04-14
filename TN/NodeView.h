
#pragma once

#include "ViewTree.h"

class CNodeViewToolBar : public CMFCToolBar
{
    virtual void OnUpdateCmdUI(CFrameWnd* /*pTarget*/, BOOL bDisableIfNoHndler)
    {
        CMFCToolBar::OnUpdateCmdUI((CFrameWnd*)GetOwner(), bDisableIfNoHndler);
    }

    virtual BOOL AllowShowOnList() const { return FALSE; }
};

class CNodeView : public CDockablePane
{
    // 构造
public:
    CNodeView();

    void AdjustLayout();
    void OnChangeVisualStyle();

    // 操作

    void clearNodeTree()
    {
        if (!m_wndNodeViewTree)
        {
            return;
        }
        
        m_wndNodeViewTree.DeleteAllItems();
    };

    HTREEITEM getRootItem()
    {
        return m_wndNodeViewTree.GetRootItem();
    };

    void setItemState(HTREEITEM item, UINT a, UINT b)
    {
        m_wndNodeViewTree.SetItemState(item, a, b);
    };
    void expand(HTREEITEM item, UINT a)
    {
        m_wndNodeViewTree.Expand(item, a);
    }

    HTREEITEM insertItem(CString cstr, UINT a, UINT b)
    {
        return m_wndNodeViewTree.InsertItem(cstr.GetBuffer(), a, b);
    };
    void insertItem(CString cstr, UINT a, UINT b, bool toRoot)
    {
        if (!toRoot)
        {
            m_wndNodeViewTree.InsertItem(cstr.GetBuffer(), a, b);
        }
        // insert to root
        HTREEITEM hRoot = NULL;
        hRoot = m_wndNodeViewTree.GetRootItem();
        m_wndNodeViewTree.InsertItem(cstr.GetBuffer(), a, b, hRoot);
        m_wndNodeViewTree.Expand(hRoot, TVE_EXPAND);
    };
    void insertItemToParent(CString newName, CString parent);
    void editItem(CString target, CString text);
    void deleteItem(CString curLabel);
    HTREEITEM findItem(CString curLabel);

    // 特性
protected:
    CViewTree m_wndNodeViewTree;
    CImageList m_NodeViewImages;
    CNodeViewToolBar m_wndToolBar;

protected:
    void FillNodeView();

    // 实现
public:
    virtual ~CNodeView();

protected:
    afx_msg int OnCreate(LPCREATESTRUCT lpCreateStruct);
    afx_msg void OnSize(UINT nType, int cx, int cy);
    afx_msg void OnContextMenu(CWnd* pWnd, CPoint point);
    afx_msg void OnProperties();
    afx_msg void OnNodeOpen();
    afx_msg void OnNodeOpenWith();
    afx_msg void OnDummyCompile();
    afx_msg void OnEditCut();
    afx_msg void OnEditCopy();
    afx_msg void OnEditClear();
    afx_msg void OnPaint();
    afx_msg void OnSetFocus(CWnd* pOldWnd);

    DECLARE_MESSAGE_MAP()
public:
    afx_msg void OnLocateNode();
};

