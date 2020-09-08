library(tm)
data("crude")
crude #VCorpus -> 객체 이름
#metadata + Cotent(문서 20개)

crude[[1]]
crude[[1]]$content
crude[[1]]$meta

#text -> corpus

text <- c('Crash dieting is not the best way to lose weight. http://bbc.in/1G0J5Agg',
          'A vegetarian diet excludes all animal flesh (meat, poultry, seafood).',
          'Economists surveyed by Refinitiv expect the economy added 160,000 jobs.')

VCorpus()#text -> Corpus해주는 함수
getSources()#text를 읽기 위해 사용할수 있는 함수
#dataframesource -> 두 열이 doc_id(문서의 아이디), text(텍스트) 있어야함 + meta data로 나머지 사용
#dirsource -> 폴더 내의 각 파일들을 하나의 corpus로 만듬
#uri -> 웹 페이지로부터 각각을 corpus로 만들어줌
#vector -> 벡터 각각을 corpus로 만듬 ...

corpus.docs <- VCorpus(VectorSource(text)) 
# ->3개의 문서로 만들고 -> 하나의 corpus생성
class(corpus.docs)

corpus.docs
inspect(corpus.docs[1])
inspect(corpus.docs[[1]]) #좀더 자세히 문자열까지도 출력
as.character(corpus.docs[[1]])
as.character(corpus.docs[[1]])
lapply(corpus.docs, as.character)

str(corpus.docs[[1]])
corpus.docs[[1]]$content
lapply(corpus.docs, content)
paste(as.vector(unlist(lapply(corpus.docs, content))), collapse = ' ')
content(corpus.docs)
meta(corpus.docs)

corpus.docs[[1]]$meta
meta(corpus.docs[[1]])$datetimestamp
meta(corpus.docs[[1]], tag = 'datetimestamp')
meta(corpus.docs[[1]], tag = 'author', type = 'local') <- 'BBC'
meta(corpus.docs[[1]])

source <- c('BBC','CNN','FOX')
meta(corpus.docs, tag = 'author', type = 'local') <- source
meta(corpus.docs, tag = 'author')

cetegory <- c('health','lifestyle','business')
meta(corpus.docs, tag = 'category', type = 'local') <- cetegory
lapply(corpus.docs, meta, tag = 'category')

meta(corpus.docs, tag = 'origin', type = 'local') <- NULL #tag 삭제
lapply(corpus.docs, meta)

corpus.docs.filtered <- tm_filter(corpus.docs,
                                  FUN = function(x) any(grep('weight|diet', content(x))))
lapply(corpus.docs.filtered, content)

idx <- meta(corpus.docs, 'author') == 'FOX' | meta(corpus.docs, 'category') == 'health'
lapply(corpus.docs[idx], content)

writeCorpus(corpus.docs)
list.files(pattern = '\\.txt')

getTransformations()

#대문자 소문자 통일
content_transformer(tolower())

corpus.docsv<- tm_map(corpus.docs, content_transformer(tolower))
lapply(corpus.docsv, content)

#영어 불용어 확인 (의미 없는 단어들)
stopwords('english')

corpus.docsv <- tm_map(corpus.docsv, removeWords, stopwords('english'))
lapply(corpus.docsv, content)

#패턴을 찾아서 제거
myRemove <- content_transformer(function(x,pattern) {
  return(gsub(pattern, '',x))
})

corpus.docsv <- tm_map(corpus.docsv, myRemove, "(f|ht)tp\\S+\\s*")
lapply(corpus.docsv, content)

corpus.docsv <- tm_map(corpus.docsv, removePunctuation)
lapply(corpus.docsv, content)

corpus.docsv <- tm_map(corpus.docsv, removeNumbers)
lapply(corpus.docsv, content)

corpus.docsv <- tm_map(corpus.docsv, stripWhitespace)
lapply(corpus.docsv, content)

corpus.docsv <- tm_map(corpus.docsv, content_transformer(trimws))
lapply(corpus.docsv, content)

# + 추가적인 전처리 작업
#ex) work, works, working -> 어간 추출 과정
#단어의 추출 빈도 계산 but 원래 단어의 형태를 잃어버림
library(SnowballC)
corpus.docsv <- tm_map(corpus.docsv, stemDocument)
lapply(corpus.docsv, content)
#올바로 작동했는지 확인을 해야함 올바로 작동을 안했을 수도 있음

corpus.docsv <- tm_map(corpus.docsv, content_transformer(gsub), pattern = 'economist', replacement = 'economi')
lapply(corpus.docsv, content)