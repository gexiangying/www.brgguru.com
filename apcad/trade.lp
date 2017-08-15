<!DOCTYPE html>
<% local apcad = _G.require("apcad.apcad") %>
<html>
<head>
<title>购买结果</title>
<%=apcad.head %>
</head>
<body>
	<div data-role="page">
		<%=apcad.header(sessionid) %>
<%
	local answer = "buy_soft\r\n-1\r\n" 
	local trade_cashs = 0
  if user and pass and soft and quantity  and price then		
    trade_cashs =_G.tonumber(quantity) * _G.tonumber(price)
		local ct = _G.socket.connect(apcad.addr,apcad.port)
		local str = "buy_soft\r\n" .. user .. "\r\n" .. pass .. "\r\n" .. soft .. "\r\n" .. quantity .. "\r\n"
		apcad.send_str(ct,str)
	  answer = apcad.recv_str(ct)
	  ct:close()
	elseif not soft then
			soft = "未输入"
  elseif not quantity then
			quantity = "未输入" 
	end
	local str
	local flag = false
  if answer ~= "buy_soft\r\n-1\r\n" then 
			flag = true
			str="购买成功"
	else
	    str="购买失败"
  end
%>
<div data-role="content">
			<ul data-role="listview" data-insert="true" data-divider-theme="a">
			<li data-role="fieldcontain">
				<h4>软件名称:<%=soft %></h4>
			</li>
			<li data-role="fieldcontain">
				<h4>购买:<%=quantity %>个月</h4>
			</li>
			<li data-role="fieldcontain">
				<h4>交易金额:<%=trade_cashs %>元</h4>
			</li>
			<li data-role="fieldcontain">
				<h4>购买结果:<%=str %></h4>
			</li>
			</ul>
</div>
<%=apcad.footer %>
	</div>
	<body>
</html>
