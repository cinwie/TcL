/*
 * Copyright (C) 2004-2012  See the AUTHORS file for details.
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License version 2 as published
 * by the Free Software Foundation.
 */

#include <znc/Nick.h>
#include <znc/IRCNetwork.h>

class CAntiIdle;

class CAntiIdleJob : public CTimer {
	public:
		CAntiIdleJob(CModule* pModule, unsigned int uInterval, 
					unsigned int uCycles, const CString& sLabel,
					const CString& sDescription)
		: CTimer(pModule, uInterval, uCycles, sLabel, sDescription) {}

	~CAntiIdleJob() override {}

	protected:
		void RunJob() override;
};

class CAntiIdle : public CModule {
	public:
		MODCONSTRUCTOR(CAntiIdle) {
			SetInterval(200);
		}

	~CAntiIdle() override {}

	bool OnLoad(const CString& sArgs, CString& sErrorMsg) override {
		if(!sArgs.Trim_n().empty())
			SetInterval(sArgs.ToInt());
		return true;
	}

	void OnModCommand( const CString& sCommand ) override {
		CString sCmdName = sCommand.Token(0).AsLower();
		if(sCmdName == "set")
		{
			CString sInterval = sCommand.Token(1, true);
			SetInterval(sInterval.ToInt());

			if(m_uiInterval == 0)
				PutModule("AntiIdle is now turned off.");
			else
				PutModule("AntiIdle is now set to " + CString(m_uiInterval) + " seconds.");
		} else if(sCmdName == "off") {
			SetInterval(0);
			PutModule("AntiIdle is now turned off");
		} else if(sCmdName == "show") {
			if(m_uiInterval == 0)
				PutModule("AntiIdle is turned off.");
			else
				PutModule("AntiIdle is set to " + CString(m_uiInterval) + " seconds.");
		} else {
			PutModule("Commands: set <seconds>, off, show");
		}
	}

	EModRet OnPrivMsg(CNick &Nick, CString &sMessage) override {
		if(Nick.GetNick() == m_pNetwork->GetIRCNick().GetNick()
				&& sMessage == "\xAE")
			return HALT;

		return CONTINUE;
	}

	EModRet OnRaw(CString &sLine) override {
		/* If we send a message to ourselfs while we are away, this
		 * will result in the server sending a 301 which we shouldn't
		 * forward to the client */

		if (sLine.Token(1).Equals("301") && sLine.Token(3).Equals(m_pNetwork->GetIRCNick().GetNick())) {
			return HALT;
		}

		return CONTINUE;
	}

private:
	void SetInterval(int i) {
		if(i < 0)
			return;

		m_uiInterval = i;

		RemTimer("AntiIdle");

		if(m_uiInterval == 0) {
			return;
		}

		AddTimer(new CAntiIdleJob(this, m_uiInterval, 0, "AntiIdle", "Periodically sends a msg to the user"));
	}

	unsigned int    m_uiInterval;
};

//! This function sends a query with (r) back to the user
void CAntiIdleJob::RunJob() {
	CString sNick = GetModule()->GetNetwork()->GetIRCNick().GetNick();
	GetModule()->PutIRC("PRIVMSG " + sNick + " :\xAE");
}

template <>
void TModInfo<CAntiIdle>(CModInfo& Info) {
    Info.SetWikiPage("antiidle");
}

NETWORKMODULEDEFS(CAntiIdle, t_s("Hides your real idle time"))