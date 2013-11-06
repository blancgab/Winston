

def compute_maximum_likelihood_estimates(self):
	self.counts.seek(0,0)
	for line in self.counts.readlines():
		split_line = line.strip().split(' ')

		if split_line[1] == 'NONTERMINAL':
			self.nonterm_counts[split_line[2]]=float(split_line[0])

		elif split_line[1] == 'UNARYRULE':
			# import pdb; pdb.set_trace()
			nonterminal = split_line[2]
			terminal = split_line[3]
			rule_counts = float(split_line[0])
			self.term_counts[terminal]+=rule_counts
			x_counts = self.nonterm_counts[nonterminal]
			self.unary_qs[nonterminal].append((terminal,(rule_counts/x_counts)))

		elif split_line[1] == 'BINARYRULE':
			self.binary_qs[split_line[2]].append((split_line[3],split_line[4],(float(split_line[0])/self.nonterm_counts[split_line[2]])))
