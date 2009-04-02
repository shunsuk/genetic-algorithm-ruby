class Genes
  attr_reader :generation, :quiz

  def initialize(gene_count = 10, quiz_length = 10)
    @gene_count = gene_count
    @quiz_length = quiz_length
    @generation = 1

    @quiz = Quiz.new(quiz_length)

    begin
      @genes = []
      gene_count.times { @genes << Gene.new(quiz_length) }
      self.mark()
      self.sort()
    end until self.max < quiz_length
  end

  def start
    while self.max < @quiz.length
      yield(self)
      self.next_genration()
      self.mark()
      self.sort()
    end
    yield(self)
  end

  def mark
    @genes.each { |g| g.score = @quiz.mark(g) }
  end

  def sort
    @genes.sort! { |a, b| b.score <=> a.score }
  end

  def next_genration
    @generation += 1
    gene1, gene2 = self.breed(@genes[0], @genes[1])
    @genes[@genes.length - 2] = gene1
    @genes[@genes.length - 1] = gene2
  end

  def breed(parent1, parent2)
    child1 = Gene.new(@quiz_length)
    child2 = Gene.new(@quiz_length)

    cross_position = rand(@quiz_length - 1)
    @quiz_length.times do |i|
      if i < cross_position
        child1[i] = parent1[i]
        child2[i] = parent2[i]
      else
        child1[i] = parent2[i]
        child2[i] = parent1[i]
      end
    end

    mutation_position = rand(@quiz_length)
    child1[mutation_position] = rand(3) if mutation_position < @quiz_length
    mutation_position = rand(@quiz_length)
    child2[mutation_position] = rand(3) if mutation_position < @quiz_length

    return child1, child2
  end

  def max
    @genes[0].score
  end

  def min
    @genes[(@genes.length - 1)].score
  end

  def average
    @genes.inject(0) { |x, g| x + g.score } / @genes.size
  end

  def [](index)
    @genes[index]
  end
end

class Gene
  attr_accessor :score
  attr_reader :length, :answers

  def initialize(length)
    @length = length
    @answers = []
    @length.times { |i| @answers << rand(3) }
  end

  def [](index)
    @answers[index]
  end

  def []=(index, value)
    @answers[index] = value
  end

  def to_s
    "[" + @answers.join(',') + "]"
  end
end

class Quiz < Gene
  def mark(answers)
    score = 0
    @length.times { |i| score += 1 if @answers[i] == answers[i] }
    score
  end
end

#--------------------------------
Genes.new.start do |genes|
  puts "Generation: #{genes.generation}"
  puts "Max: #{genes.max}, Average: #{genes.average}"
  puts "A #{genes.quiz}"
  puts "--------------------------------"

  10.times do |i|
    puts "#{i} #{genes[i]} #{genes[i].score}"
  end
  break if gets =~ /x/
end
