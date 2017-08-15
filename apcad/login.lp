<% local apcad = _G.require("apcad.apcad") %>
<%
	local logined = false
	local M = {}
	local softs
	local ct = _G.socket.connect(apcad.addr,apcad.port)
	local str="login\r\n" ..user .. "\r\n" .. psw .. "\r\n"
	apcad.send_str(ct,str)
	local answer = apcad.recv_str(ct)
	if (answer == "login\r\n-1\r\n") then
	logined = false 
	else
	local cmd = "get_softs\r\n"	
	apcad.send_str(ct,cmd)
	apcad.farse_recv(ct,M)
	softs = M.softs

	cmd = "get_balance\r\n" .. user .. "\r\n" .. psw .. "\r\n"
	apcad.send_str(ct,cmd)
	apcad.farse_recv(ct,M) 

	cmd = "get_trades\r\n" .. user .. "\r\n" .. psw .. "\r\n"
	apcad.send_str(ct,cmd)
	apcad.farse_recv(ct,M)

	logined = true
	end
	ct:close()
%>
<div data-role="page" id="main">
<% if logined then %>
<div data-role="content">
<ul data-role="listview" data-insert="true" data-divider-theme="a">
<% if M.balance then %>
<li data-role="list-divider">用户信息</li>
<li>用户名:<%=user %></li>
<li>账户余额:<%=M.balance %></li>
<% end %>
<li data-role="list-divider">软件列表</li>
<%
 for k,v in _G.ipairs(softs) do 
	local m = {}
	m.user = user
	m.pass = _G.luaext.md5(psw)
	m.soft = k
	m.price = v.price
	m.sessionid = sessionid
	local ref_str = "soft.lp?" .. url.encodetable(m)
	%>
	<li> <a href="<%=ref_str %>"><%= k %></a> </li>
	<% end %>

	<li data-role="list-divider">交易记录</li>
	<li>
	<table width="100%" class="ui-responsive table-stripe" >
	<thead>
	<tr>
	<th>软件名称</th>
	<th>购买时间</th>
	<th>到期日期</th>
	</tr>
	</thead>
	<tbody>
	<tr>
	<%
	for k,v in _G.pairs(M.trades) do
	local softname = v.softname
	local startdate = v.date
	local enddate = v.expire or (v.date + v.months * 60*60*24*30)
	local start_str = _G.os.date("%x",startdate) 
	local end_str = _G.os.date("%x",enddate)
	%>
	<td><%=softname %></td>
	<td><%=start_str %></td>
	<td><%=end_str %></td>
	</tr>
	<% end %>
	</tbody>
	</table>
	</li>

</ul>
</div>
<% else %>
<h1>login error!</h1>
<% end %>
</div>
