<!DOCTYPE html>
<% local apcad = _G.require("apcad.apcad") %>
<html>
	<head>
		<title>register</title>
		<%=apcad.head %>
	</head>
	<body>
		<%
		 local result = ""
		 if user and pass and email and phone then
				local id = _G.luaext.guid()
				local ct = _G.socket.connect(apcad.addr,apcad.port)
				local str = "reg\r\n" .. user .. "\r\n" .. pass .. "\r\n" .. id .. "\r\n" .. email .. "\r\n" .. phone .. "\r\n"
				apcad.send_str(ct,str)
				result = apcad.recv_str(ct)
		 else
			result = "please input username password email phone "
		 end
		%>
		<div data-role="page">
			<%=apcad.header() %>
			<div data-role="content">
				<ul data-role="listview" data-insert="true">
					<li data-role="fieldcontain">
						<h4><%=result %></h4>
					</li>
				</ul>
			</div>
			<%=apcad.footer %>
		</div>
	</body>
</html>
