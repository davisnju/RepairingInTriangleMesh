
#pragma once

/////////////////////////////////////////////////////////////////////////////
// CViewTree 窗口

class CViewTree : public CTreeCtrl
{
    // 构造
public:
    CViewTree();

    // 重写
protected:
    virtual BOOL OnNotify(WPARAM wParam, LPARAM lParam, LRESULT* pResult);

    // 实现
public:
    virtual ~CViewTree();

    //item:待遍历树的根节点，strtext:待查找节点名称
    HTREEITEM findItem(HTREEITEM item, CString strtext);

protected:
    DECLARE_MESSAGE_MAP()
public:
    afx_msg void OnNMDblclk(NMHDR *pNMHDR, LRESULT *pResult);
};
