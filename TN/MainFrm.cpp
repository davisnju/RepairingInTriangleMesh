
// MainFrm.cpp : CMainFrame 类的实现
//

#include "stdafx.h"
#include "TNApp.h"
#include "TNDoc.h"
#include "TNView.h"

#include "MainFrm.h"

#include <string>
#include <stdlib.h>

#ifdef _DEBUG
#define new DEBUG_NEW
#endif

// CMainFrame

IMPLEMENT_DYNCREATE(CMainFrame, CFrameWndEx)

const int  iMaxUserToolbars = 10;
const UINT uiFirstUserToolBarId = AFX_IDW_CONTROLBAR_FIRST + 40;
const UINT uiLastUserToolBarId = uiFirstUserToolBarId + iMaxUserToolbars - 1;

BEGIN_MESSAGE_MAP(CMainFrame, CFrameWndEx)
    ON_WM_CREATE()
    ON_COMMAND(ID_VIEW_CUSTOMIZE, &CMainFrame::OnViewCustomize)
    ON_REGISTERED_MESSAGE(AFX_WM_CREATETOOLBAR, &CMainFrame::OnToolbarCreateNew)
    ON_COMMAND_RANGE(ID_VIEW_APPLOOK_WIN_2000, ID_VIEW_APPLOOK_WINDOWS_7, &CMainFrame::OnApplicationLook)
    ON_UPDATE_COMMAND_UI_RANGE(ID_VIEW_APPLOOK_WIN_2000, ID_VIEW_APPLOOK_WINDOWS_7, &CMainFrame::OnUpdateApplicationLook)
    ON_WM_SETTINGCHANGE()

    ON_UPDATE_COMMAND_UI(ID_OSG_ORBIT, &CMainFrame::OnUpdateOsgOrbit)
    ON_UPDATE_COMMAND_UI(ID_OSG_PAN, &CMainFrame::OnUpdateOsgPan)
    ON_UPDATE_COMMAND_UI(ID_OSG_SELECT, &CMainFrame::OnUpdateOsgSelect)
    ON_UPDATE_COMMAND_UI(ID_OSG_SCALE, &CMainFrame::OnUpdateOsgScale)

    ON_MESSAGE(WM_USER_THREADEND, &CMainFrame::OnHandleOutputBuildStr)
    ON_MESSAGE(WM_USER_PROP, &CMainFrame::OnHandleSetProp)
    ON_MESSAGE(WM_USER_ADDMODELNAME, &CMainFrame::OnHandleUpdateNodeView)
    ON_MESSAGE(WM_USER_EDITMODELNAME, &CMainFrame::OnEditNodeView)
    ON_MESSAGE(WM_USER_EDITMODELLABEL, &CMainFrame::OnHandleAddLabelProp)
    ON_MESSAGE(WM_USER_DBCLKLABEL, &CMainFrame::OnUserDbclklabel)

    ON_UPDATE_COMMAND_UI(ID_OSG_ADDMD, &CMainFrame::OnUpdateOsgAddmd)
    ON_UPDATE_COMMAND_UI(ID_OSG_ADDEF, &CMainFrame::OnUpdateOsgAddef)
    ON_UPDATE_COMMAND_UI(ID_OSG_ROTATE, &CMainFrame::OnUpdateOsgRotate)
    ON_UPDATE_COMMAND_UI(ID_OSG_TRANS, &CMainFrame::OnUpdateOsgTrans)
    ON_UPDATE_COMMAND_UI(ID_OSG_ADDLABEL, &CMainFrame::OnUpdateOsgAddlabel)
    ON_WM_CLOSE()
    ON_COMMAND(ID_RECTIFY_H, &CMainFrame::OnRectifyH)
END_MESSAGE_MAP()

static UINT indicators[] =
{
    ID_SEPARATOR,           // 状态行指示器
    ID_INDICATOR_CAPS,
    ID_INDICATOR_NUM,
    ID_INDICATOR_SCRL,
};

// CMainFrame 构造/析构

CMainFrame::CMainFrame()
{

    theApp.m_nAppLook = theApp.GetInt(_T("ApplicationLook"), ID_VIEW_APPLOOK_VS_2008);
}

CMainFrame::~CMainFrame()
{}

int CMainFrame::OnCreate(LPCREATESTRUCT lpCreateStruct)
{
    if (CFrameWndEx::OnCreate(lpCreateStruct) == -1)
        return -1;
    

    BOOL bNameValid;

    if (!m_wndMenuBar.Create(this))
    {
        TRACE0("未能创建菜单栏\n");
        return -1;      // 未能创建
    }

    m_wndMenuBar.SetPaneStyle(m_wndMenuBar.GetPaneStyle() | CBRS_SIZE_DYNAMIC | CBRS_TOOLTIPS | CBRS_FLYBY);

    // 防止菜单栏在激活时获得焦点
    CMFCPopupMenu::SetForceMenuFocus(FALSE);

    if (!m_wndToolBar.CreateEx(this, TBSTYLE_FLAT, WS_CHILD | WS_VISIBLE | CBRS_TOP | CBRS_GRIPPER | CBRS_TOOLTIPS | CBRS_FLYBY | CBRS_SIZE_DYNAMIC) ||
        !m_wndToolBar.LoadToolBar(theApp.m_bHiColorIcons ? IDR_MAINFRAME_256 : IDR_MAINFRAME))
    {
        TRACE0("未能创建工具栏\n");
        return -1;      // 未能创建
    }

    CString strToolBarName;
    bNameValid = strToolBarName.LoadString(IDS_TOOLBAR_STANDARD);
    ASSERT(bNameValid);
    m_wndToolBar.SetWindowText(strToolBarName);

    CString strCustomize;
    bNameValid = strCustomize.LoadString(IDS_TOOLBAR_CUSTOMIZE);
    ASSERT(bNameValid);
    m_wndToolBar.EnableCustomizeButton(TRUE, ID_VIEW_CUSTOMIZE, strCustomize);

    // 允许用户定义的工具栏操作: 
    InitUserToolbars(NULL, uiFirstUserToolBarId, uiLastUserToolBarId);

    if (!m_wndStatusBar.Create(this))
    {
        TRACE0("未能创建状态栏\n");
        return -1;      // 未能创建
    }
    m_wndStatusBar.SetIndicators(indicators, sizeof(indicators) / sizeof(UINT));

    // TODO:  如果您不希望工具栏和菜单栏可停靠，请删除这五行
    m_wndMenuBar.EnableDocking(CBRS_ALIGN_ANY);
    m_wndToolBar.EnableDocking(CBRS_ALIGN_ANY);
    EnableDocking(CBRS_ALIGN_ANY);
    DockPane(&m_wndMenuBar);
    DockPane(&m_wndToolBar);


    // 启用 Visual Studio 2005 样式停靠窗口行为
    CDockingManager::SetDockingMode(DT_SMART);
    // 启用 Visual Studio 2005 样式停靠窗口自动隐藏行为
    EnableAutoHidePanes(CBRS_ALIGN_ANY);

    // 加载菜单项图像(不在任何标准工具栏上): 
    CMFCToolBar::AddToolBarForImageCollection(IDR_MENU_IMAGES, theApp.m_bHiColorIcons ? IDB_MENU_IMAGES_24 : 0);

    // 创建停靠窗口
    if (!CreateDockingWindows())
    {
        TRACE0("未能创建停靠窗口\n");
        return -1;
    }

    m_wndNodeView.EnableDocking(CBRS_ALIGN_ANY);
    // m_wndClassView.EnableDocking(CBRS_ALIGN_ANY);
    DockPane(&m_wndNodeView);
    //CDockablePane* pTabbedBar = NULL;
    //m_wndClassView.AttachToTabWnd(&m_wndNodeView, DM_SHOW, FALSE, &pTabbedBar);
    m_wndOutput.EnableDocking(CBRS_ALIGN_ANY);
    m_wndOutput.ShowPane(FALSE, FALSE, FALSE);
    DockPane(&m_wndOutput);
    m_wndProperties.EnableDocking(CBRS_ALIGN_ANY);
    DockPane(&m_wndProperties);
    m_wndProperties.ShowPane(FALSE, FALSE, FALSE);

    // 基于持久值设置视觉管理器和样式
    OnApplicationLook(theApp.m_nAppLook);

    // 启用工具栏和停靠窗口菜单替换
    EnablePaneMenu(TRUE, ID_VIEW_CUSTOMIZE, strCustomize, ID_VIEW_TOOLBAR);

    // 启用快速(按住 Alt 拖动)工具栏自定义
    CMFCToolBar::EnableQuickCustomization();

    if (CMFCToolBar::GetUserImages() == NULL)
    {
        // 加载用户定义的工具栏图像
        if (m_UserImages.Load(_T(".\\UserImages.bmp")))
        {
            CMFCToolBar::SetUserImages(&m_UserImages);
        }
    }

    //// 启用菜单个性化(最近使用的命令)
    //// TODO:  定义您自己的基本命令，确保每个下拉菜单至少有一个基本命令。
    //CList<UINT, UINT> lstBasicCommands;

    //lstBasicCommands.AddTail(ID_FILE_NEW);
    //lstBasicCommands.AddTail(ID_FILE_OPEN);
    //lstBasicCommands.AddTail(ID_FILE_SAVE);
    //lstBasicCommands.AddTail(ID_FILE_PRINT);
    //lstBasicCommands.AddTail(ID_APP_EXIT);
    //lstBasicCommands.AddTail(ID_EDIT_CUT);
    //lstBasicCommands.AddTail(ID_EDIT_PASTE);
    //lstBasicCommands.AddTail(ID_EDIT_UNDO);
    //lstBasicCommands.AddTail(ID_APP_ABOUT);
    //lstBasicCommands.AddTail(ID_VIEW_STATUS_BAR);
    //lstBasicCommands.AddTail(ID_VIEW_TOOLBAR);
    //lstBasicCommands.AddTail(ID_VIEW_APPLOOK_OFF_2003);
    //lstBasicCommands.AddTail(ID_VIEW_APPLOOK_VS_2005);
    //lstBasicCommands.AddTail(ID_VIEW_APPLOOK_OFF_2007_BLUE);
    //lstBasicCommands.AddTail(ID_VIEW_APPLOOK_OFF_2007_SILVER);
    //lstBasicCommands.AddTail(ID_VIEW_APPLOOK_OFF_2007_BLACK);
    //lstBasicCommands.AddTail(ID_VIEW_APPLOOK_OFF_2007_AQUA);
    //lstBasicCommands.AddTail(ID_VIEW_APPLOOK_WINDOWS_7);
    //lstBasicCommands.AddTail(ID_SORTING_SORTALPHABETIC);
    //lstBasicCommands.AddTail(ID_SORTING_SORTBYTYPE);
    //lstBasicCommands.AddTail(ID_SORTING_SORTBYACCESS);
    //lstBasicCommands.AddTail(ID_SORTING_GROUPBYTYPE);

    //CMFCToolBar::SetBasicCommands(lstBasicCommands);

    return 0;
}

BOOL CMainFrame::PreCreateWindow(CREATESTRUCT& cs)
{
    if (!CFrameWndEx::PreCreateWindow(cs))
        return FALSE;
    // TODO:  在此处通过修改 CREATESTRUCT cs 来修改窗口类或样式

    return TRUE;
}

BOOL CMainFrame::CreateDockingWindows()
{
    BOOL bNameValid;

    // 创建类视图
    //CString strClassView;
    //bNameValid = strClassView.LoadString(IDS_CLASS_VIEW);
    //ASSERT(bNameValid);
    //if (!m_wndClassView.Create(strClassView, this, CRect(0, 0, 200, 200), TRUE, ID_VIEW_CLASSVIEW, WS_CHILD | WS_VISIBLE | WS_CLIPSIBLINGS | WS_CLIPCHILDREN | CBRS_LEFT | CBRS_FLOAT_MULTI))
    //{
    //    TRACE0("未能创建“类视图”窗口\n");
    //    return FALSE; // 未能创建
    //}

    // 创建节点视图
    CString strFileView;
    bNameValid = strFileView.LoadString(IDS_FILE_VIEW);
    ASSERT(bNameValid);
    if (!m_wndNodeView.Create(strFileView, this, CRect(0, 0, 200, 200), TRUE, ID_VIEW_FILEVIEW, WS_CHILD | WS_VISIBLE | WS_CLIPSIBLINGS | WS_CLIPCHILDREN | CBRS_LEFT | CBRS_FLOAT_MULTI))
    {
        TRACE0("未能创建“节点视图”窗口\n");
        return FALSE; // 未能创建
    }

    // 创建输出窗口
    CString strOutputWnd;
    bNameValid = strOutputWnd.LoadString(IDS_OUTPUT_WND);
    ASSERT(bNameValid);
    if (!m_wndOutput.Create(strOutputWnd, this, CRect(0, 0, 100, 100), TRUE, ID_VIEW_OUTPUTWND, WS_CHILD | WS_VISIBLE | WS_CLIPSIBLINGS | WS_CLIPCHILDREN | CBRS_BOTTOM | CBRS_FLOAT_MULTI))
    {
        TRACE0("未能创建输出窗口\n");
        return FALSE; // 未能创建
    }

    // 创建属性窗口
    CString strPropertiesWnd;
    bNameValid = strPropertiesWnd.LoadString(IDS_PROPERTIES_WND);
    ASSERT(bNameValid);
    if (!m_wndProperties.Create(strPropertiesWnd, this, CRect(0, 0, 200, 200), TRUE, ID_VIEW_PROPERTIESWND, WS_CHILD | WS_VISIBLE | WS_CLIPSIBLINGS | WS_CLIPCHILDREN | CBRS_RIGHT | CBRS_FLOAT_MULTI))
    {
        TRACE0("未能创建“属性”窗口\n");
        return FALSE; // 未能创建
    }

    SetDockingWindowIcons(theApp.m_bHiColorIcons);
    return TRUE;
}

void CMainFrame::SetDockingWindowIcons(BOOL bHiColorIcons)
{
    HICON hNodeViewIcon = (HICON) ::LoadImage(::AfxGetResourceHandle(), MAKEINTRESOURCE(bHiColorIcons ? IDI_FILE_VIEW_HC : IDI_FILE_VIEW), IMAGE_ICON, ::GetSystemMetrics(SM_CXSMICON), ::GetSystemMetrics(SM_CYSMICON), 0);
    m_wndNodeView.SetIcon(hNodeViewIcon, FALSE);

    //HICON hClassViewIcon = (HICON) ::LoadImage(::AfxGetResourceHandle(), MAKEINTRESOURCE(bHiColorIcons ? IDI_CLASS_VIEW_HC : IDI_CLASS_VIEW), IMAGE_ICON, ::GetSystemMetrics(SM_CXSMICON), ::GetSystemMetrics(SM_CYSMICON), 0);
    //m_wndClassView.SetIcon(hClassViewIcon, FALSE);

    HICON hOutputBarIcon = (HICON) ::LoadImage(::AfxGetResourceHandle(), MAKEINTRESOURCE(bHiColorIcons ? IDI_OUTPUT_WND_HC : IDI_OUTPUT_WND), IMAGE_ICON, ::GetSystemMetrics(SM_CXSMICON), ::GetSystemMetrics(SM_CYSMICON), 0);
    m_wndOutput.SetIcon(hOutputBarIcon, FALSE);

    HICON hPropertiesBarIcon = (HICON) ::LoadImage(::AfxGetResourceHandle(), MAKEINTRESOURCE(bHiColorIcons ? IDI_PROPERTIES_WND_HC : IDI_PROPERTIES_WND), IMAGE_ICON, ::GetSystemMetrics(SM_CXSMICON), ::GetSystemMetrics(SM_CYSMICON), 0);
    m_wndProperties.SetIcon(hPropertiesBarIcon, FALSE);

}

// CMainFrame 诊断

#ifdef _DEBUG
void CMainFrame::AssertValid() const
{
    CFrameWndEx::AssertValid();
}

void CMainFrame::Dump(CDumpContext& dc) const
{
    CFrameWndEx::Dump(dc);
}
#endif //_DEBUG


// CMainFrame 消息处理程序

void CMainFrame::OnViewCustomize()
{
    CMFCToolBarsCustomizeDialog* pDlgCust = new CMFCToolBarsCustomizeDialog(this, TRUE /* 扫描菜单*/);
    pDlgCust->EnableUserDefinedToolbars();
    pDlgCust->Create();
}

LRESULT CMainFrame::OnToolbarCreateNew(WPARAM wp, LPARAM lp)
{
    LRESULT lres = CFrameWndEx::OnToolbarCreateNew(wp, lp);
    if (lres == 0)
    {
        return 0;
    }

    CMFCToolBar* pUserToolbar = (CMFCToolBar*)lres;
    ASSERT_VALID(pUserToolbar);

    BOOL bNameValid;
    CString strCustomize;
    bNameValid = strCustomize.LoadString(IDS_TOOLBAR_CUSTOMIZE);
    ASSERT(bNameValid);

    pUserToolbar->EnableCustomizeButton(TRUE, ID_VIEW_CUSTOMIZE, strCustomize);
    return lres;
}

void CMainFrame::OnApplicationLook(UINT id)
{
    CWaitCursor wait;

    theApp.m_nAppLook = id;

    switch (theApp.m_nAppLook)
    {
    case ID_VIEW_APPLOOK_WIN_2000:
        CMFCVisualManager::SetDefaultManager(RUNTIME_CLASS(CMFCVisualManager));
        break;

    case ID_VIEW_APPLOOK_OFF_XP:
        CMFCVisualManager::SetDefaultManager(RUNTIME_CLASS(CMFCVisualManagerOfficeXP));
        break;

    case ID_VIEW_APPLOOK_WIN_XP:
        CMFCVisualManagerWindows::m_b3DTabsXPTheme = TRUE;
        CMFCVisualManager::SetDefaultManager(RUNTIME_CLASS(CMFCVisualManagerWindows));
        break;

    case ID_VIEW_APPLOOK_OFF_2003:
        CMFCVisualManager::SetDefaultManager(RUNTIME_CLASS(CMFCVisualManagerOffice2003));
        CDockingManager::SetDockingMode(DT_SMART);
        break;

    case ID_VIEW_APPLOOK_VS_2005:
        CMFCVisualManager::SetDefaultManager(RUNTIME_CLASS(CMFCVisualManagerVS2005));
        CDockingManager::SetDockingMode(DT_SMART);
        break;

    case ID_VIEW_APPLOOK_VS_2008:
        CMFCVisualManager::SetDefaultManager(RUNTIME_CLASS(CMFCVisualManagerVS2008));
        CDockingManager::SetDockingMode(DT_SMART);
        break;

    case ID_VIEW_APPLOOK_WINDOWS_7:
        CMFCVisualManager::SetDefaultManager(RUNTIME_CLASS(CMFCVisualManagerWindows7));
        CDockingManager::SetDockingMode(DT_SMART);
        break;

    default:
        switch (theApp.m_nAppLook)
        {
        case ID_VIEW_APPLOOK_OFF_2007_BLUE:
            CMFCVisualManagerOffice2007::SetStyle(CMFCVisualManagerOffice2007::Office2007_LunaBlue);
            break;

        case ID_VIEW_APPLOOK_OFF_2007_BLACK:
            CMFCVisualManagerOffice2007::SetStyle(CMFCVisualManagerOffice2007::Office2007_ObsidianBlack);
            break;

        case ID_VIEW_APPLOOK_OFF_2007_SILVER:
            CMFCVisualManagerOffice2007::SetStyle(CMFCVisualManagerOffice2007::Office2007_Silver);
            break;

        case ID_VIEW_APPLOOK_OFF_2007_AQUA:
            CMFCVisualManagerOffice2007::SetStyle(CMFCVisualManagerOffice2007::Office2007_Aqua);
            break;
        }

        CMFCVisualManager::SetDefaultManager(RUNTIME_CLASS(CMFCVisualManagerOffice2007));
        CDockingManager::SetDockingMode(DT_SMART);
    }

    m_wndOutput.UpdateFonts();
    RedrawWindow(NULL, NULL, RDW_ALLCHILDREN | RDW_INVALIDATE | RDW_UPDATENOW | RDW_FRAME | RDW_ERASE);

    theApp.WriteInt(_T("ApplicationLook"), theApp.m_nAppLook);
}

void CMainFrame::OnUpdateApplicationLook(CCmdUI* pCmdUI)
{
    pCmdUI->SetRadio(theApp.m_nAppLook == pCmdUI->m_nID);
}


BOOL CMainFrame::LoadFrame(UINT nIDResource, DWORD dwDefaultStyle, CWnd* pParentWnd, CCreateContext* pContext)
{
    // 基类将执行真正的工作

    if (!CFrameWndEx::LoadFrame(nIDResource, dwDefaultStyle, pParentWnd, pContext))
    {
        return FALSE;
    }


    // 为所有用户工具栏启用自定义按钮
    BOOL bNameValid;
    CString strCustomize;
    bNameValid = strCustomize.LoadString(IDS_TOOLBAR_CUSTOMIZE);
    ASSERT(bNameValid);

    for (int i = 0; i < iMaxUserToolbars; i++)
    {
        CMFCToolBar* pUserToolbar = GetUserToolBarByIndex(i);
        if (pUserToolbar != NULL)
        {
            pUserToolbar->EnableCustomizeButton(TRUE, ID_VIEW_CUSTOMIZE, strCustomize);
        }
    }

    return TRUE;
}


void CMainFrame::OnSettingChange(UINT uFlags, LPCTSTR lpszSection)
{
    CFrameWndEx::OnSettingChange(uFlags, lpszSection);
    m_wndOutput.UpdateFonts();
}


void CMainFrame::OnUpdateOsgOrbit(CCmdUI *pCmdUI)
{
    CTNApp *app = (CTNApp *)AfxGetApp();
    int naviMode = app->naviMode;

    pCmdUI->SetCheck(naviMode == NAVI_MODE_ORBIT);

}


void CMainFrame::OnUpdateOsgPan(CCmdUI *pCmdUI)
{
    CTNApp *app = (CTNApp *)AfxGetApp();
    int naviMode = app->naviMode;

    pCmdUI->SetCheck(naviMode == NAVI_MODE_PAN);
}


void CMainFrame::OnUpdateOsgSelect(CCmdUI *pCmdUI)
{
    CTNApp *app = (CTNApp *)AfxGetApp();
    int naviMode = app->naviMode;

    pCmdUI->SetCheck(naviMode == NAVI_MODE_SELECT);
}


afx_msg LRESULT CMainFrame::OnHandleOutputBuildStr(WPARAM wParam, LPARAM lParam)
{
    // clearBuildString();
    CString str;
    str.Format(_T("%s"), (lParam));
    addBuildString(str);
    return 0;
}

// 设置节点视图
afx_msg LRESULT CMainFrame::OnHandleUpdateNodeView(WPARAM wParam, LPARAM lParam)
{
    CString cstr;
    cstr.Format(_T("%s"), (lParam));

    bool toRoot = wParam == NULL;
    if (toRoot)
    {
        insertNodeNameToRoot(cstr, 2, 2);
    }
    else
    {
        CString parent = cstr, newName;
        cstr.Format(_T("%s"), (wParam));
        newName = cstr;
        m_wndNodeView.insertItemToParent(newName, parent);
    }
    return 0;
}

afx_msg LRESULT CMainFrame::OnEditNodeView(WPARAM wParam, LPARAM lParam)
{
    CString cstr;
    cstr.Format(_T("%s"), (lParam));
    CString target = cstr, text;
    cstr.Format(_T("%s"), (wParam));
    text = cstr;
    m_wndNodeView.editItem(target, text);

    return 0;
}

afx_msg LRESULT CMainFrame::OnHandleSetProp(WPARAM wParam, LPARAM lParam)
{
    CString str;
    str.Format(_T("%s"), (lParam));
    setModelProp(str);
    // addBuildString(str);
    return 0;
}

void CMainFrame::setModelProp(CString cstr)
{
    CString modelName = cstr.Left(cstr.Find('$'))
        , propStr = cstr.Right(cstr.GetLength() - cstr.Find('$') - 1)
        , tstr, pistr;
    int propNum = cstr.Replace(_T(","), _T(",")) + 1
        , curPID = 0;

    // addBuildString(modelName);

    CString propValue[10] = { 0 };
    tstr = propStr;
    int i;
    for (i = 0; i < propNum - 1; i++)
    {
        pistr = tstr.Left(tstr.Find(_T(',')));
        propValue[i] = pistr;
        tstr = tstr.Right(tstr.GetLength() - tstr.Find(',') - 1);
    }
    propValue[i] = tstr;

    int propListPropNum = m_wndProperties.m_wndPropList.GetPropertyCount();
    //tstr.Format(_T("已有属性 %d 条"), propListPropNum);//5
    //addBuildString(tstr);

    CString pnamestr;
    bool existFlag = false;
    for (int i = 0; i < propListPropNum; i++)
    {
        pnamestr = m_wndProperties.m_wndPropList.GetProperty(i)->GetName();
        curPID += m_wndProperties.m_wndPropList.GetProperty(i)->GetSubItemsCount();
        if (pnamestr == "选定模型")
        {
            if (cstr == "")
            {
                // 清除“选定模型”属性
                CMFCPropertyGridProperty* pModelGroup = m_wndProperties.m_wndPropList.GetProperty(i);
                m_wndProperties.m_wndPropList.DeleteProperty(pModelGroup);
                existFlag = false;
                m_wndProperties.ShowPane(FALSE, FALSE, FALSE);
            }
            else
            {
                existFlag = true;
                m_wndProperties.m_wndPropList.GetProperty(i)
                    ->GetSubItem(0)->SetValue(
                    modelName.Left(modelName.ReverseFind('.')));

                m_wndProperties.m_wndPropList.GetProperty(i)
                    ->GetSubItem(1)->SetValue(
                    modelName.Right(modelName.GetLength() - modelName.ReverseFind('.') - 1));

                m_wndProperties.m_wndPropList.GetProperty(i)
                    ->GetSubItem(2)->SetValue(propValue[0]);

                m_wndProperties.m_wndPropList.GetProperty(i)
                    ->GetSubItem(3)->SetValue(propValue[1]);

                m_wndProperties.m_wndPropList.GetProperty(i)
                    ->GetSubItem(4)->SetValue(propValue[2]);
                m_wndProperties.ShowPane(TRUE, FALSE, FALSE);
            }
            break;
        }
    }
    if (cstr != "" && !existFlag)
    {
        m_wndProperties.selModelNamePID = curPID;
        CMFCPropertyGridProperty* pModelGroup = new CMFCPropertyGridProperty(
            _T("选定模型"));
        CMFCPropertyGridProperty* pModelProp = new CMFCPropertyGridProperty(
            _T("名称"), modelName.Left(modelName.ReverseFind('.'))
            , _T(""), curPID++);
        pModelProp->AllowEdit(true);
        pModelGroup->AddSubItem(pModelProp);

        pModelProp = new CMFCPropertyGridProperty(
            _T("类型"), modelName.Right(modelName.GetLength() - modelName.ReverseFind('.') - 1)
            , _T(""), curPID++);
        pModelProp->AllowEdit(FALSE);
        pModelGroup->AddSubItem(pModelProp);

        pModelProp = new CMFCPropertyGridProperty(
            _T("中心x"), propValue[0], _T(""), curPID++);
        pModelProp->AllowEdit(FALSE);
        pModelGroup->AddSubItem(pModelProp);

        pModelProp = new CMFCPropertyGridProperty(
            _T("中心y"), propValue[1], _T(""), curPID++);
        pModelProp->AllowEdit(FALSE);
        pModelGroup->AddSubItem(pModelProp);

        pModelProp = new CMFCPropertyGridProperty(
            _T("中心z"), propValue[2], _T(""), curPID++);
        pModelProp->AllowEdit(FALSE);
        pModelGroup->AddSubItem(pModelProp);
        m_wndProperties.m_wndPropList.AddProperty(pModelGroup);
        m_wndProperties.ShowPane(TRUE, FALSE, FALSE);
    }
}

afx_msg LRESULT CMainFrame::OnHandleAddLabelProp(WPARAM wParam, LPARAM lParam)
{
    CMainFrame* pFrame = (CMainFrame*)AfxGetApp()->GetMainWnd();
    CTNDoc* doc = (CTNDoc*)pFrame->GetActiveDocument();
    CString path = doc->m_datapath, propIni = doc->m_inipath;

    CString cstrLabel, cstrValue, cstrPropName, cstrPropValue;
    cstrLabel.Format(_T("%s"), (wParam));// 标签名
    if (wParam == NULL)
    {
        m_curLabel = "";
        int propListPropNum = m_wndProperties.m_wndPropList.GetPropertyCount();
        CString pnamestr;
        int labelPropGroupID = 0;
        bool existFlag = false;
        for (int i = 0; i < propListPropNum; i++)
        {
            pnamestr = m_wndProperties.m_wndPropList.GetProperty(i)->GetName();
            if (pnamestr == "标签")
            {
                existFlag = true;
                labelPropGroupID = i;
                break;
            }
        }
        if (existFlag)
        {
            // 清除已有“标签”属性组下的属性
            CMFCPropertyGridProperty* pModelGroup
                = m_wndProperties.m_wndPropList.GetProperty(labelPropGroupID);
            m_wndProperties.m_wndPropList.DeleteProperty(pModelGroup);
        }
        m_wndProperties.ShowPane(FALSE, FALSE, FALSE);
        return 0;
    }
    else if (lParam == NULL)
    {
        // 查看属性
        m_curLabel = cstrLabel;
        int propListPropNum = m_wndProperties.m_wndPropList.GetPropertyCount();
        CString pnamestr;
        int labelPropGroupID = 0;
        bool existFlag = false;
        for (int i = 0; i < propListPropNum; i++)
        {
            pnamestr = m_wndProperties.m_wndPropList.GetProperty(i)->GetName();
            if (pnamestr == "标签")
            {
                existFlag = true;
                labelPropGroupID = i;
                break;
            }
        }
        CMFCPropertyGridProperty* pModelGroup;
        if (existFlag)
        {
            // 清除已有“标签”属性组下的属性
            pModelGroup = m_wndProperties.m_wndPropList.GetProperty(labelPropGroupID);
            m_wndProperties.m_wndPropList.DeleteProperty(pModelGroup);
        }
        pModelGroup = new CMFCPropertyGridProperty(L"标签");
        m_wndProperties.m_wndPropList.AddProperty(pModelGroup);
        int curPID = labelPropGroupID * 100;
        CMFCPropertyGridProperty* pModelProp = new CMFCPropertyGridProperty(
            L"名称", cstrLabel, cstrLabel + L"\r\n(标签的唯一标识符)", curPID++);
        pModelProp->AllowEdit(true);
        pModelGroup->AddSubItem(pModelProp);

        if (::PathFileExists(propIni))
        {
            propListPropNum = m_wndProperties.m_wndPropList.GetPropertyCount();
            for (int i = 0; i < propListPropNum; i++)
            {
                pnamestr = m_wndProperties.m_wndPropList.GetProperty(i)->GetName();
                if (pnamestr == "标签")
                {
                    labelPropGroupID = i;
                    break;
                }
            }
            CString tcstr;
            TCHAR szKeyValue[MAX_PROP_LEN] = { 0 };
            int nValue = 0; // 属性数目
            nValue = ::GetPrivateProfileInt(
                cstrLabel, TEXT("PropNum"), 0, propIni);
            for (int i = 0; i < nValue; i++)
            {
                // 读取属性
                tcstr.Format(L"PropName%d",i);
                ::GetPrivateProfileString(cstrLabel,
                                          tcstr, NULL,
                                          szKeyValue, MAX_PROP_LEN,
                                          propIni);
                cstrPropName = szKeyValue;
                tcstr.Format(L"PropValue%d", i);
                ::GetPrivateProfileString(cstrLabel,
                                          tcstr, NULL,
                                          szKeyValue, MAX_PROP_LEN,
                                          propIni);
                cstrPropValue = szKeyValue;
                // 添加到属性窗口
                cstrPropValue.Replace(L"\\r\\n", L"\r\n");
                pModelProp = new CMFCPropertyGridProperty(
                    cstrPropName, cstrPropValue, cstrPropValue, curPID++);
                pModelProp->AllowEdit(true);
                pModelGroup->AddSubItem(pModelProp);
            }
        }
        m_wndProperties.OnExpandAllProperties();
        m_wndProperties.ShowPane(TRUE, FALSE, FALSE);
    }
    else
    {
        // 添加编辑标签cstrLabel属性，修改Label名或属性值
        cstrValue.Format(_T("%s"), (lParam));// 属性值对
        CString cstrLabelName;
        if (cstrValue.Find(L"$", 0) > -1)
        {
            cstrLabelName = cstrValue.Left(cstrValue.Find(L"$", 0));
        }
        else
        {
            cstrLabelName = cstrValue;
        }
        if (cstrLabelName != cstrLabel)
        {
            m_curLabel = cstrLabelName;
            // 修改节点视图中的Label名    
            m_wndNodeView.editItem(cstrLabel, cstrLabelName);
            // NameSet中的Label名    
            CTNApp *app = (CTNApp *)AfxGetApp();
            app->nodeNameSet.erase(app->nodeNameSet.find(cstrLabel));
            app->insertNodeName2(cstrLabelName);
        }
        m_wndProperties.OnExpandAllProperties();
        m_wndProperties.ShowPane(TRUE, FALSE, FALSE);
    }

    return 0;
}

void CMainFrame::OnUpdateOsgAddmd(CCmdUI *pCmdUI)
{
    CTNApp *app = (CTNApp *)AfxGetApp();
    int editMode = app->editMode;

    pCmdUI->SetCheck(editMode == EDIT_MODE_ADD_MODEL);
}


void CMainFrame::OnUpdateOsgAddlabel(CCmdUI *pCmdUI)
{
    CTNApp *app = (CTNApp *)AfxGetApp();
    int editMode = app->editMode;

    pCmdUI->SetCheck(editMode == EDIT_MODE_ADD_LABEL);
}


void CMainFrame::OnUpdateOsgAddef(CCmdUI *pCmdUI)
{
    CTNApp *app = (CTNApp *)AfxGetApp();
    int editMode = app->editMode;

    pCmdUI->SetCheck(editMode == EDIT_MODE_ADD_FIRE);
}


void CMainFrame::OnUpdateOsgRotate(CCmdUI *pCmdUI)
{
    CTNApp *app = (CTNApp *)AfxGetApp();
    int editMode = app->editMode;

    pCmdUI->SetCheck(editMode == EDIT_MODE_ROTATE);
}


void CMainFrame::OnUpdateOsgTrans(CCmdUI *pCmdUI)
{
    CTNApp *app = (CTNApp *)AfxGetApp();
    int editMode = app->editMode;

    pCmdUI->SetCheck(editMode == EDIT_MODE_TRANS);
}

void CMainFrame::OnUpdateOsgScale(CCmdUI *pCmdUI)
{
    CTNApp *app = (CTNApp *)AfxGetApp();
    int editMode = app->editMode;

    pCmdUI->SetCheck(editMode == EDIT_MODE_SCALE);
}

// ---------------- 节点视图 -------------------
void CMainFrame::insertRootNodeName(CString cstr)
{
    //插入根节点  
    m_wndNodeView.clearNodeTree();
    HTREEITEM hRoot = m_wndNodeView.insertItem(cstr, 0, 0);
    m_wndNodeView.setItemState(hRoot, TVIS_BOLD, TVIS_BOLD);
    m_wndNodeView.expand(hRoot, TVE_EXPAND);
    hRoot = NULL;
}
void CMainFrame::insertNodeNameToRoot(CString cstr, UINT a, UINT b)
{
    //插入到根节点  
    m_wndNodeView.insertItem(cstr, a, b, true);
}


void CMainFrame::insertNameToParent(CString newName, CString parent)
{
    //插入到指定父节点  
    m_wndNodeView.insertItemToParent(newName, parent);
}

void CMainFrame::deleteLabel(CString curLabel)
{
    m_wndNodeView.deleteItem(curLabel);

    CTNApp *app = (CTNApp *)AfxGetApp();
    app->nodeNameSet.erase(app->nodeNameSet.find(curLabel));

    CTNView* pView = (CTNView*)this->GetActiveView();
    pView->mOSG->deleteLabel(curLabel);
}


afx_msg LRESULT CMainFrame::OnUserDbclklabel(WPARAM wParam, LPARAM lParam)
{
    CString cstrLabel;
    cstrLabel.Format(_T("%s"), (lParam));// 双击的标签名称
    
    // AfxMessageBox(L"You have selected " + cstr);
    CTNView* pView = (CTNView*)this->GetActiveView();
    pView->mOSG->moveCameratoLabel(cstrLabel);
    OnHandleAddLabelProp(WPARAM(cstrLabel.GetBuffer(cstrLabel.GetAllocLength())), (LPARAM)NULL);
    return 0;
}


void CMainFrame::OnClose()
{
    if (::MessageBox(NULL, L"确定退出程序？",
        L"提示", MB_YESNO) == IDYES)
    {
        CFrameWndEx::OnClose();
    }
}


void CMainFrame::OnRectifyH()
{
    // TODO:  在此添加命令处理程序代码
    CTNView* pView = (CTNView*)this->GetActiveView();
    pView->mOSG->RectifyH();
}
