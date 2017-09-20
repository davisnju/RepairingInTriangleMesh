
#include "stdafx.h"
#include "ViewTree.h"
#include "MainFrm.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CViewTree

CViewTree::CViewTree()
{}

CViewTree::~CViewTree()
{}

BEGIN_MESSAGE_MAP(CViewTree, CTreeCtrl)
    ON_NOTIFY_REFLECT(NM_DBLCLK, &CViewTree::OnNMDblclk)
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CViewTree 消息处理程序

BOOL CViewTree::OnNotify(WPARAM wParam, LPARAM lParam, LRESULT* pResult)
{
    BOOL bRes = CTreeCtrl::OnNotify(wParam, lParam, pResult);

    NMHDR* pNMHDR = (NMHDR*)lParam;
    ASSERT(pNMHDR != NULL);

    if (pNMHDR && pNMHDR->code == TTN_SHOW && GetToolTips() != NULL)
    {
        GetToolTips()->SetWindowPos(&wndTop, -1, -1, -1, -1, SWP_NOMOVE | SWP_NOACTIVATE | SWP_NOSIZE);
    }

    return bRes;
}

HTREEITEM CViewTree::findItem(HTREEITEM item, CString strtext)
{
    HTREEITEM hfind;
    //空树，直接返回NULL
    if (item == NULL)
        return NULL;

    //遍历查找
    while (item != NULL)
    {
        //当前节点即所需查找节点
        if (GetItemText(item) == strtext)
            return item;
        
        //查找当前节点的子节点
        if (ItemHasChildren(item))
        {
            item = GetChildItem(item);
            //递归调用查找子节点下节点
            hfind = findItem(item, strtext);
            if (hfind)
            {
                return hfind;
            }
            else //子节点中未发现所需节点，继续查找兄弟节点
                item = GetNextSiblingItem(GetParentItem(item));
        }
        else
        { //若无子节点，继续查找兄弟节点
            item = GetNextSiblingItem(item);
        }
    }
    return item;
}

void CViewTree::OnNMDblclk(NMHDR *pNMHDR, LRESULT *pResult)
{
    HTREEITEM hTreeItem = GetSelectedItem();
    //以GetItemText()函数为例：   
    CString cstr = GetItemText(hTreeItem);
    // AfxMessageBox(L"You have selected " + cstr);
    CMainFrame* pFrame = (CMainFrame*)AfxGetApp()->GetMainWnd();
    pFrame->OnUserDbclklabel(NULL, (LPARAM)cstr.GetBuffer(cstr.GetAllocLength()));
    *pResult = 0;
}