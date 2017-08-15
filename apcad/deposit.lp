<!DOCTYPE html>
<% local apcad = _G.require("apcad.apcad") %>
<html>
	<head>
		<title>Deposit</title>
		<%=apcad.head %>
	</head>
	<body>
		<div data-role="page">
			<%=apcad.header() %>
			<div data-role="content">
				<form action="deposit.lp" method="post">
					<ul data-role="listview" data-insert="true">
						<li data-role="fieldcontain">
							<label for="user">用户名称:</label>
								<input type = "text" name = "user" id="user">
						</li>
						<li data-role="fieldcontain">
							<label for="pass">密码:</label>
								<input type="password" name="pass" id = "pass">
						</li>
						<li data-role="fieldcontain">
							<label for="cashs">充值数额:</label>
								<input type="number" name="cashs" id = "cashs">
						</li>
						<li data-role="fieldcontain">
							<input type = "submit" value = "确认" data-theme="b">
						</li>
					</ul>
				</form>
				<%
			 if user and pass and cashs then
		     ct = _G.socket.connect(apcad.addr,apcad.port)
				 local str="deposit\r\n" ..user .. "\r\n" .. pass .. "\r\n" .. cashs .. "\r\n"
				 apcad.send_str(ct,str)
				 ct:close()
			 end
			%>

	</body>
</html>
