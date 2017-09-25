
// TNDoc.cpp : CTNDoc 类的实现
//

#include "stdafx.h"
// SHARED_HANDLERS 可以在实现预览、缩略图和搜索筛选器句柄的
// ATL 项目中进行定义，并允许与该项目共享文档代码。
#ifndef SHARED_HANDLERS
#include "TNApp.h"
#endif

#include "TNDoc.h"
#include "MainFrm.h"
#include "TNView.h"

#include <propkey.h>

#include <fstream>
#include <iostream>

#ifdef _DEBUG
#define new DEBUG_NEW
#endif

// CTNDoc

IMPLEMENT_DYNCREATE(CTNDoc, CDocument)

BEGIN_MESSAGE_MAP(CTNDoc, CDocument)
    ON_COMMAND(ID_SCENE_SAVE, &CTNDoc::OnSceneSave)
    ON_COMMAND(ID_FILE_OPEN, &CTNDoc::OnFileOpen)
    ON_COMMAND(ID_FILE_SAVE, &CTNDoc::OnFileSave)
    ON_COMMAND(ID_FILE_SAVE_AS, &CTNDoc::OnFileSaveAs)
END_MESSAGE_MAP()


// CTNDoc 构造/析构

CTNDoc::CTNDoc()
{
}

CTNDoc::~CTNDoc()
{}

BOOL CTNDoc::OnNewDocument()
{
    if (!CDocument::OnNewDocument())
        return FALSE;

    // (SDI 文档将重用该文档)
    // 得到exe执行路径.  
    TCHAR tcExePath[MAX_PATH] = { 0 };
    ::GetModuleFileName(NULL, tcExePath, MAX_PATH);
    // 设置ini路径到exe同一目录下  
#ifndef CONFIG_FILE  
#define CONFIG_FILE     (TEXT("setting.ini"))  
#endif  
    //_tcsrchr() 反向搜索获得最后一个'\\'的位置，并返回该位置的指针  
    TCHAR *pFind = _tcsrchr(tcExePath, '\\');
    if (pFind != NULL)
    {
        *pFind = '\0';
    }

    CString szIniPath = tcExePath;
    szIniPath += "\\";
    m_path = szIniPath; // 当前exe路径
    szIniPath += CONFIG_FILE;

    //下面执行读取 ----------------------------------  
    if (::PathFileExists(szIniPath))
    {
        TCHAR szKeyValue[MAX_PATH] = { 0 };
        int nValue = 0;
        ::GetPrivateProfileString(TEXT("Environment"), TEXT("Path"), 
                                  NULL, szKeyValue, MAX_PATH, 
                                  szIniPath);
        //nValue = ::GetPrivateProfileInt(TEXT("Environment"), TEXT("Path"), 0, szIniPath);
        m_datapath = szKeyValue;
        // CString lastchar = m_datapath.Right(1);
        if (m_datapath.Right(1) != L"\\"
            && m_datapath.Right(1) != L"/")
        {
            m_datapath += L"\\";
        }
        m_inipath = m_datapath + L"默认项目.ini";
        if (::PathFileExists(m_datapath + L"默认项目.ini"))
        {
            DeleteFile(m_inipath);
        }
        CFile   file;
        file.Open(m_datapath + L"默认项目.ini", CFile::modeCreate);
        file.Close();
        initModelZ = ::GetPrivateProfileInt(
            TEXT("Environment"), TEXT("initModelZ"), 0, szIniPath);
        memset(szKeyValue,0, MAX_PATH);
        ::GetPrivateProfileString(TEXT("Scene"), TEXT("initModelName"),
                                  NULL, szKeyValue, MAX_PATH,
                                  szIniPath);
        if (szKeyValue[0] != '\0')
        {
            m_initModelName = m_datapath + szKeyValue;
            // 设置程序标题栏
            CMainFrame* pFrame = (CMainFrame*)AfxGetApp()->GetMainWnd();
            pFrame->SetWindowTextW(m_initModelName + L" - Scene Editor");
        }
        else
        {
            m_initModelName = L"";
        }
    }
       
    return TRUE;
}




// CTNDoc 序列化

void CTNDoc::Serialize(CArchive& ar)
{
    if (ar.IsStoring())
    {
        // 保存

    }
    else
    {
       // 加载

    }
}

#ifdef SHARED_HANDLERS

// 缩略图的支持
void CTNDoc::OnDrawThumbnail(CDC& dc, LPRECT lprcBounds)
{
    // 修改此代码以绘制文档数据
    dc.FillSolidRect(lprcBounds, RGB(255, 255, 255));

    CString strText = _T("TODO: implement thumbnail drawing here");
    LOGFONT lf;

    CFont* pDefaultGUIFont = CFont::FromHandle((HFONT) GetStockObject(DEFAULT_GUI_FONT));
    pDefaultGUIFont->GetLogFont(&lf);
    lf.lfHeight = 36;

    CFont fontDraw;
    fontDraw.CreateFontIndirect(&lf);

    CFont* pOldFont = dc.SelectObject(&fontDraw);
    dc.DrawText(strText, lprcBounds, DT_CENTER | DT_WORDBREAK);
    dc.SelectObject(pOldFont);
}

// 搜索处理程序的支持
void CTNDoc::InitializeSearchContent()
{
    CString strSearchContent;
    // 从文档数据设置搜索内容。
    // 内容部分应由“;”分隔

    // 例如:     strSearchContent = _T("point;rectangle;circle;ole object;")；
    SetSearchContent(strSearchContent);
}

void CTNDoc::SetSearchContent(const CString& value)
{
    if (value.IsEmpty())
    {
        RemoveChunk(PKEY_Search_Contents.fmtid, PKEY_Search_Contents.pid);
    }
    else
    {
        CMFCFilterChunkValueImpl *pChunk = NULL;
        ATLTRY(pChunk = new CMFCFilterChunkValueImpl);
        if (pChunk != NULL)
        {
            pChunk->SetTextValue(PKEY_Search_Contents, value, CHUNK_TEXT);
            SetChunkValue(pChunk);
        }
    }
}

#endif // SHARED_HANDLERS

// CTNDoc 诊断

#ifdef _DEBUG
void CTNDoc::AssertValid() const
{
    CDocument::AssertValid();
}

void CTNDoc::Dump(CDumpContext& dc) const
{
    CDocument::Dump(dc);
}
#endif //_DEBUG


// CTNDoc 命令


void CTNDoc::OnSceneSave()
{
    // 保存场景
    CMainFrame* pFrame = (CMainFrame*)AfxGetApp()->GetMainWnd();
    CTNDoc* doc = (CTNDoc*)pFrame->GetActiveDocument();
    CTNView* view = (CTNView*)pFrame->GetActiveView();

    BOOL isOpen = FALSE;     //是否打开(否则为保存)  
    CString defaultDir = doc->m_datapath;   //默认打开的文件路径  
    CString fileName = L"";         //默认打开的文件名  
    CString filter = L"文件 (*.osg; *.osgb)|*.osg; *.osgb||";   //文件过虑的类型  
    CFileDialog openFileDlg(isOpen, defaultDir, fileName, OFN_HIDEREADONLY | OFN_READONLY, filter, NULL);
    openFileDlg.GetOFN().lpstrInitialDir = defaultDir;
    INT_PTR result = openFileDlg.DoModal();
    CString filePath = defaultDir;
    int confirmed = -1;
    if (result == IDOK)
    {
        filePath = openFileDlg.GetPathName();
        if (::PathFileExists(filePath))
        {
            if (::MessageBox(NULL, L"替换已存在文件？",
                L"提示", MB_YESNO) == IDYES)
            {
                confirmed = 2;
            }
        }
        else
        {
            confirmed = 1;
        }

    }
    if (confirmed > 0)
    {
        m_projname = openFileDlg.GetFileTitle();
        m_inipath = m_datapath + m_projname + L".ini";
        // 设置程序标题栏
        pFrame->SetWindowTextW(filePath + L" - Scene Editor");
        view->saveScene(filePath, confirmed);
    }
}


void CTNDoc::OnFileOpen()
{
    // 加载场景
    CMainFrame* pFrame = (CMainFrame*)AfxGetApp()->GetMainWnd();
    CTNView* view = (CTNView*)pFrame->GetActiveView();

    BOOL isOpen = TRUE;     //是否打开(否则为保存)  
    CString defaultDir = m_datapath;   //默认打开的文件路径  
    CString fileName = L"";         //默认打开的文件名  
    CString filter = L"文件 (*.osg; *.osgb)|*.osg; *.osgb||";   //文件过虑的类型  
    CFileDialog openFileDlg(isOpen, defaultDir, fileName, OFN_HIDEREADONLY | OFN_READONLY, filter, NULL);
    openFileDlg.GetOFN().lpstrInitialDir = defaultDir;
    INT_PTR result = openFileDlg.DoModal();
    CString filePath = defaultDir;
    bool confirmed = false;
    if (result == IDOK)
    {
        filePath = openFileDlg.GetPathName();
        m_projname = openFileDlg.GetFileTitle();
        m_inipath = m_datapath + m_projname + L".ini";

        if (!::PathFileExists(filePath))
        {
            AfxMessageBox(L"文件不存在！");
        }
        //else if (!::PathFileExists(m_inipath))
        //{
        //    AfxMessageBox(L"非法项目文件，因为项目附带属性文件不存在！");
        //}
        //else
        {
            confirmed = true;
        }

    }
    if (confirmed)
    {
        // 设置程序标题栏
        pFrame->SetWindowTextW(filePath + L" - Scene Editor");
        view->loadScene(filePath);
    }
}


void CTNDoc::OnFileSave()
{
    CTNDoc::OnSceneSave();
}


void CTNDoc::OnFileSaveAs()
{
    CTNDoc::OnSceneSave();
}


void CTNDoc::OnCloseDocument()
{
    // 删除默认项目.ini
    if (::PathFileExists(m_datapath + L"默认项目.ini"))
    {
        DeleteFile(m_datapath + L"默认项目.ini");
    }
    CDocument::OnCloseDocument();
}
