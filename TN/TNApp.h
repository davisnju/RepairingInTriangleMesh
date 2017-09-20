
// TN.h : TN 应用程序的主头文件
//
#pragma once

#ifndef __AFXWIN_H__
#error "在包含此文件之前包含“stdafx.h”以生成 PCH 文件"
#endif

#include "resource.h"       // 主符号

#include <iostream>

#include <set>

// CTNApp:
// 有关此类的实现，请参阅 TN.cpp
//

class CTNApp : public CWinAppEx
{
public:
    CTNApp();

    // 浏览模式
    int naviMode;
    bool naviModeChanged;

    // 编辑模式
    int editMode;
    bool editModeChanged;

    std::set<CString> nodeNameSet;

    void clearNameSet()
    {
        nodeNameSet.clear();
    }

    int insertNodeName(CString str)
    {
        std::pair<std::set<CString>::iterator, bool> pr;
        pr = nodeNameSet.insert(str);
        if (pr.second)
        {
            // 更新节点视图
            onUpdateNodeView(str);
            // 插入位置
            std::set<CString>::iterator it = pr.first;
            return 0;
        }
        return -1;
    }
    int insertNodeName2(CString str)
    {
        std::pair<std::set<CString>::iterator, bool> pr;
        pr = nodeNameSet.insert(str);
        if (pr.second)
        {
            // 插入位置
            std::set<CString>::iterator it = pr.first;
            return 0;
        }
        return -1;
    }
    void onUpdateNodeView(CString str);

    // 重写
public:
    virtual BOOL InitInstance();
    virtual int ExitInstance();

    // 实现
    UINT  m_nAppLook;
    BOOL  m_bHiColorIcons;

    virtual void PreLoadState();
    virtual void LoadCustomState();
    virtual void SaveCustomState();

    afx_msg void OnAppAbout();
    DECLARE_MESSAGE_MAP()
};

extern CTNApp theApp;
