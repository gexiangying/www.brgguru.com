<!DOCTYPE html> 
<% local tour = _G.require("brg.tour") %>
<html> 
	<head> 
		<title>精英群排行榜</title> 
		<%=tour.head %>
	</head> 
	<body>
		<div data-role="page">
			<div data-role="content">
				<form action="master.lp" method="POST" autocomplete="off">
					<ul data-role="listview" data-insert="true">

						<li data-role="fieldcontain">
							<label for="tourdate">比赛日期:</label>
							<% if tourdate then %>
							<input type="date" name="tourdate" id="tourdate" value="<%=tourdate %>">
							<% else %>
							<input type="date" name="tourdate" id="tourdate" >
							<% end %>
						</li>

						<li data-role="fieldcontain">
							<fieldset data-role="controlgroup">
								<legend>时间段:</legend>
								<label for="morning">上午</label>
								<% if segment and segment == "上午" then %>
								<input type="radio" name="segment" id="morning" value="上午" checked>
								<% else %>
								<input type="radio" name="segment" id="morning" value="上午">
								<% end %>
								<label for="afternoon">下午</label>
								<% if segment and segment == "下午" then %>
								<input type="radio" name="segment" id="afternoon" value="下午" checked>
								<% else %>
								<input type="radio" name="segment" id="afternoon" value="下午">
								<% end %>
							</fieldset>
						</li>
						<li data-role="fieldcontain">
							<label for="name">姓名:</label>
								<select name="name" id="name" >
									<option value="大牛">大牛</option>
									<option value="大连老张">大连老张</option>
									<option value="飞帆">飞帆</option>
									<option value="老虎">老虎</option>
									<option value="三炮">三炮</option>
									<option value="大连小刀客">大连小刀客</option>
									<option value="胖">胖</option>
									<option value="大连老狼">大连老狼</option>
									<option value="老唐大连">老唐大连</option>
									<option value="刘智国">刘智国</option>
									<option value="台山">台山</option>
									<option value="大连博士">大连博士</option>
									<option value="wiily_he">wiily_he</option>
								</select>
						</li>
							
            <li data-role="fieldcontain">
							<label for="imps">imps:</label>
							<input type="number" name="imps" id="imps" >
						</li>

						<li data-role="fieldcontain">
							<input type="submit" value="确认" data-theme="a" >
						</li>
					</ul>
				</form>
			</div>
			<% local db = tour.load_master() %>
			<% if tourdate and segment and name and imps then %>
			<% db[tourdate] = db[tourdate] or {} %>
			<% db[tourdate][segment] = db[tourdate][segment] or {} %>
			<% db[tourdate][segment][name] = _G.tonumber(imps) %>
			<% tour.save_master(db) %>
			<% end %>
			<div data-role="content">
				<table width="100%" class="ui-responsive table-stripe" >
					<thead>
						<tr>
							<th >序号</th>
							<th >日期</th>
							<th >时段</th>
							<th >姓名</th>
							<th >imps</th>
						</tr>
					</thead>
					<tbody>
						<% for k,v in _G.pairs(db) do %>
						<% if tourdate and k == tourdate then %>
						<% for k1,v1 in _G.pairs(v) do %>
						<% local keys = {} %>
						<% for k2,v2 in _G.pairs(v1) do %>
						<% local temp = {} %>
						<% temp.k = k2 %>
						<% temp.v = v2 %>
						<% keys[#keys+1] = temp %>
						<% end %>
						<% _G.table.sort(keys, function(a,b) return a.v > b.v end) %>
						<% local no = 0 %>
					  <% for i,v3 in _G.ipairs(keys) do %>	
						<% no = no + 1 %>
						<tr>
							<td><%=no %></td>
							<td><%=k %></td>
							<td><%=k1 %></td>
							<td><%=v3.k %></td>
							<td><%=v3.v %></td>
						</tr>
						<% end %>
						<% end %>
						<% end %>
						<% end %>
					</tbody>
				</table>
			</div>
		</div>
	</body>
</html>	
