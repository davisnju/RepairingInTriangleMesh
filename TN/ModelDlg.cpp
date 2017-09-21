// ModelDlg.cpp : 实现文件
//

#include "stdafx.h"
#include "ModelDlg.h"
#include "afxdialogex.h"

#include <vector>
using namespace std;

// CModelDlg 对话框

vector<LPWSTR> CModelDlg::models = { TEXT("三棱锥"), TEXT("三棱台"), TEXT("四棱锥"), TEXT("四棱台"),
TEXT("长方体"), TEXT("球"), TEXT("圆柱"), TEXT("圆锥"), TEXT("圆台") };

IMPLEMENT_DYNAMIC(CModelDlg, CDialogEx)

CModelDlg::CModelDlg(CWnd* pParent /*=NULL*/)
	: CDialogEx(CModelDlg::IDD, pParent)
    , m_NodeName(_T(""))
    , m_SelModelName(_T(""))
{
}

CModelDlg::~CModelDlg()
{
}

void CModelDlg::DoDataExchange(CDataExchange* pDX)
{
    CDialogEx::DoDataExchange(pDX);
    DDX_Control(pDX, IDC_LIST_ITEM, m_ModelItemList);
    DDX_Text(pDX, IDC_EDIT_NODE_NAME, m_NodeName);
    DDX_Text(pDX, IDC_EDIT_MODEL, m_SelModelName);
}


BEGIN_MESSAGE_MAP(CModelDlg, CDialogEx)
    ON_BN_CLICKED(IDOK, &CModelDlg::OnBnClickedOk)
    ON_NOTIFY(NM_CLICK, IDC_LIST_ITEM, &CModelDlg::OnNMClickListItem)
END_MESSAGE_MAP()


// CModelDlg 消息处理程序


BOOL CModelDlg::OnInitDialog()
{
    CDialogEx::OnInitDialog();
    
    HICON m_hIcon;
    m_hIcon = LoadIcon(AfxGetApp()->m_hInstance, MAKEINTRESOURCE(IDR_MAINFRAME));//载入图标,IDR_NEW已在资源里添/加好了
    
    m_imgList.Create(48, 48, ILC_MASK | ILC_COLOR, 1, 4);
    m_imgList.Add(m_hIcon);

    m_ModelItemList.SetImageList(&m_imgList, LVSIL_NORMAL);//

    int n = models.size();
    for (int Index = 0; Index < n; ++Index)
    {
        LVITEM item;
        item.mask = LVIF_IMAGE | LVIF_TEXT;
        item.iImage = 0;
        item.pszText = models[Index];
        item.iItem = Index;
        item.iSubItem = 0;
        m_ModelItemList.InsertItem(&item);

    }

    return TRUE;  // return TRUE unless you set the focus to a control
    // 异常:  OCX 属性页应返回 FALSE
}


void CModelDlg::OnBnClickedOk()
{
    UpdateData(TRUE);
    m_ModelName = m_SelModelName;
    CDialogEx::OnOK();
}


void CModelDlg::OnNMClickListItem(NMHDR *pNMHDR, LRESULT *pResult)
{
    LPNMITEMACTIVATE pNMItemActivate = reinterpret_cast<LPNMITEMACTIVATE>(pNMHDR);
    // TODO:  在此添加控件通知处理程序代码
    int item = pNMItemActivate->iItem;
    m_SelModelName = m_ModelItemList.GetItemText(item, 0);
    UpdateData(FALSE);
    *pResult = 0;
}
