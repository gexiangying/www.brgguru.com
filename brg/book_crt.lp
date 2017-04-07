<!DOCTYPE html> 
<% local book = _G.require("brg.book") %>
<html> 
	<head> 
		<title>创建账本</title> 
    <%=book.head %>
	</head> 
	<body>
    <%
      local db = {} 
			%>
		<div data-role="page">
			 <%=book.header %>
			 <div data-role="content">
       <% if not bookname or not passwd then %>
					<h4>请输入账本名称和密码</h4>
       <% else 
           db = book.load_book(bookname) or {}
           if db.passwd then
       %>
          <h4>账本已存在</h4>
           <% else %>
           <% db.passwd = passwd 
				 book.save_book(bookname,db) %>
          <h4>创建账本<%=bookname %>成功</h4>
          <% end %>
       <% end %>
			</div>
      <%=book.footer %>
		</div>
	</body>
</html>

