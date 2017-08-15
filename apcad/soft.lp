<!DOCTYPE html>
<% local apcad = _G.require("apcad.apcad") %>
<% local url = _G.require("lpp.url") %>
<html>
<head>
<title>Welcome to apcad!</title>
<%=apcad.head %>
</head>
<body>
 <div data-role="page">
	 <%=apcad.header(sessionid) %>
	 <%
			local href_str = "trade.lp"
			if sessionid then
			href_str = href_str .. "?sessionid=" .. url.escape(sessionid)
			end
			%>
	 <div data-role="content">
		 <form action=<%=href_str %> method="post">
			<ul data-role="listview" data-insert="true" data-divider-theme="a">
			<li data-role="fieldcontain">
				<label>软件名称:<%=soft %></label>
			</li>
			<li data-role="fieldcontain">
				<label>软件价格(人民币/每月):<%=price %></label>
			</li>
			<li data-role="fieldcontain">
				<label for="quantity">购买月数</label>
				<input type="number" name="quantity" id="quantity" min="1" max="12" >
			</li>
			<input type="hidden" name="user" value="<%=user %>" >
			<input type="hidden" name="pass" value="<%=pass %>" >
			<input type="hidden" name="soft" value="<%=soft %>" >
			<input type="hidden" name="price" value="<%=price %>" >
			<li data-role="fieldcontain">
					<input type = "submit" value = "购买" data-theme="b">
			</li>
			</ul>
		</form>

	 </div>

	<% local downloadstr = _G.string.sub(soft,1,2) .. "/" .. soft .. ".zip" %>
	<div data-role="content">
				<a href="<%=downloadstr %>" data-ajax="false">下载软件</a>
	</div>
	 <%=apcad.footer %>

 </div>

</body>
</html>
