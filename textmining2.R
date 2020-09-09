text <- c('Crash dieting is not the best way to lose weight. http://bbc.in/1G0J4Agg',
          'A vegetarian diet excludes all animal flesh (meat, poultry, seafood).',
          'Economists surveyed by Refinitive expect the economy added 160,000 jobs.')
source <- c('BBC','CNN','FOX')

#문자열 -> tidy
#문자열 -> dataframe -> tidy

library(dplyr)
tibble(text, source)
text.df <- tibble(source = source, text = text)
text.df
class(text.df)

library(tidytext)
unnest_tokens(tbl = text.df, output = word, input = text)
#text에 포함된 단어의 개수 = 행의 수

tidy.docs <- text.df %>% unnest_tokens(output = word, input = text)

##tidy text와 corpus가 다른점
#corpus형식의 경우 corpus의 함수를 사용해야함
#tidy text의 경우 r기본 함수 사용 가능
tidy.docs %>% count(source)
tidy.docs %>% group_by(source) %>% summarise(n = n())

#조건에 맞는 특정 행을 제외함
removed <- tibble(word = c('http','bbc.in','1g0j4agg'))
anti_join(tidy.docs, removed, by = 'word')
tidy.docs <- anti_join(tidy.docs, removed, by = 'word')
tidy.docs$word

#숫자 삭제 using 정규표현식
grep('\\d+', tidy.docs$word)
tidy.docs <- tidy.docs[-grep('\\d+', tidy.docs$word),]
tidy.docs

#tidy text로 변경하기 전에 삭제
text.df$text <- gsub('(f|ht)tp:\\S+\\s*','',text.df$text)
text.df$text <- gsub('\\d+','',text.df$text)

tidy.docs <- text.df %>% unnest_tokens(output = word, input = text)
tidy.docs %>% print(n = Inf)

#불용어 제거
stop_words #불용어 data.frame
tidy.docs <- tidy.docs %>% anti_join(stop_words, by = 'word')
tidy.docs$word

#공백 삭제
tidy.docs$word <- gsub('\\s+','',tidy.docs$word) 

#어간추출
library(SnowballC)
tidy.docs <- tidy.docs %>% mutate(word = wordStem(word))
tidy.docs$word

#대체하는 방법
tidy.docs$word <- gsub('economist','economi',tidy.docs$word)
tidy.docs$word

#corpus -> tidy text
library(tm)
text
corpus.docs<- VCorpus(VectorSource(text))
corpus.docs
meta(corpus.docs, tag = 'author', type = 'local') <- source
tidy(corpus.docs) #metadata + text를 열로 가짐
tidy(corpus.docs) %>% unnest_tokens(word, text) %>% select(author, word)
