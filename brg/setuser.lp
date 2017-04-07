<!DOCTYPE html> 
<% local tour = _G.require("brg.tour") %>
<html> 
	<head> 
		<title>管理后台</title> 
		<%=tour.head %>
	</head> 
	<body>
	
	<div data-role="page">
			<%=tour.header %>
			<div data-role="content" class="ui-field-contain">	
				<form action="brg.lp" method="POST" autocomplete="off">
					<ul data-role="listview" data-inset="true">
						<li data-role="fieldcontain">
							<label for="N_no">北家编号</label>
							<input type="number" name="N_no" id="N_no">
						</li>
						<li data-role="fieldcontain">
							<label for="S_no">南家编号</label>
							<input type="number" name="S_no" id="S_no">
						</li>
						<li data-role="fieldcontain">
							<label for="E_no">东家编号</label>
							<input type="number" name="E_no" id="E_no">
						</li>
						<li data-role="fieldcontain">
							<label for="W_no">西家编号</label>
							<input type="number" name="W_no" id="W_no">
						</li>
					  <input type="hidden" name="tour_no" value="<%=tour_no %>"/>
						<input type="hidden" name="round" value="<%=round %>"/>
						<input type="hidden" name="desk" value="<%=desk %>"/>
						<input type="hidden" name="passwd" value="<%=passwd %>"/>
						<li data-role="fieldcontain">
							<input type="submit" value="确认" data-theme="a" >
						</li>
					</ul>
				</form>	
			</div><!-- /内容 -->
     <%=tour.footer %>
		</div>
	</body>
</html>
